require 'xmlrpc/server'

#Allow blog discovery
module XMLRPC
  class WEBrickServlet < BasicServer
    alias :post_only_service :service
    def service(request, response)
      if request.request_method == 'GET'
        if (request.query_string == 'rsd')
          response.status = 200
          response['Content-Type']   = 'text/xml; charset=utf-8'
          root_url='http://localhost:4004'
          xmlrpc_url='http://localhost:4004/xmlrpc.php'
          blogID='1'
          response.body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><rsd version=\"1.0\" xmlns=\"http://archipelago.phrasewise.com/rsd\"><service><engineName>Movable Type</engineName><engineLink>http://moveabletype.org/</engineLink><homePageLink>#{root_url}</homePageLink><apis><api name=\"Movable Type\" blogID=\"#{blogID}\" preferred=\"true\" apiLink=\"#{xmlrpc_url}\" /><api name=\"MetaWeblog\" blogID=\"#{blogID}\" preferred=\"false\" apiLink=\"#{xmlrpc_url}\" /><api name=\"Blogger\" blogID=\"#{blogID}\" preferred=\"false\" apiLink=\"#{xmlrpc_url}\" /></apis></service></rsd>"
          response['Content-Length'] = response.body.length
          return
        end
        raise WEBrick::HTTPStatus::MethodNotAllowed,
              "unsupported method `#{request.request_method}'."

      end

      if (request['Content-type'].nil?)
        request['Content-type']="text/xml"
      end

      return post_only_service(request,response)
    end
  end
end