require 'yaml'
require 'rexml/document'
require 'open-uri'
require 'mechanize'
require 'pp'

class RSSParser
  def initialize
    @agent = Mechanize.new
  end

  def parse(rss_uri, text_xpath)
    uri = URI.parse(rss_uri)
    doc = REXML::Document.new(open(uri))

    news = []

    REXML::XPath.match(doc, 'rss/channel/item').each do |obj|
      news << scrap(obj.elements['link'].text, text_xpath)
    end

    news
  end

  def scrap(uri, text_xpath)
    page = @agent.get(URI.parse(uri))

    # title
    title = page.xpath('//title[name(..)="head"]').text.strip
    # link
    link = page.xpath('//link[@rel="canonical"][name(..)="head"]/@href').text.strip
    # text
    text = []

    page.xpath(text_xpath).each do |node|
      temp = node.xpath('p')

      text << temp if !temp.empty?
    end

    text = text.join("\n")

    {:title => title, :link => link, :text => text}
  end
end
