# frozen_string_literal: true

require "uri"

# helpers for MagicLinks
module MagicLinksHelper
  # returns a fully-qualified URL from a member and a path. Use in lieu of
  # url_for when you want magic link.
  # usage: magic_link_to(member, @event.title, unit_events_path(current_unit, @event))
  # returns (e.g.) https://go.scoutplan.org/123456789abc
  def magic_url_for(member, options)
    return nil unless member

    path = url_for(options) # let the router compute the path
    magic_link = MagicLink.generate_link(member, path) # create a MagicLink object
    magic_link_url(token: magic_link.token) # generated by router
  end

  # Works like link_to with an added UnitMembership value in the first position.
  # Only returns relative paths.
  def magic_link_to(member, name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}
    path = magic_url_for(member, options)

    if block_given?
      link_to(path, html_options, &block)
    else
      link_to(name, path, html_options)
    end
  end

  # def url_to_magic_link(member, url)
  #   uri = URI(url)

  #   path = uri.request_uri # everything after "https://go.scoutplan.org/"

  # end
end
