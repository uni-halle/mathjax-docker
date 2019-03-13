# MathJax Server

Docker-ized version of the [**mathjax-server**](https://github.com/tiarno/mathjax-server).

> Node server listens for MathJax POST, returns rendered math.
> MathJax is an open-source JavaScript display engine for LaTeX, MathML, and AsciiMath notation that works in all modern browsers. It was designed with the goal of consolidating the recent advances in web technologies into a single, definitive, math-on-the-web platform supporting the major browsers and operating systems.

* Server-Side rendering
* PNG support

It was written to assist our [ILIAS](https://github.com/ILIAS-eLearning/ILIAS/blob/release_5-4/Services/MathJax/docs/Install-MathJax-Server.txt) instance in generating PDFs, but might be useful for other purposes as well.

This Docker files / image aims to facilitate setting up the MathJax Server in an isolated environment, either as part of the docker(-compose) network on the same host as ILIAS, or distributed to another physical or virtual host. This service does not require a connection to ILIAS or its database; however ILIAS must be able to connect to this service in order to be useful. Users of ILIAS do not need connect to this service directly, instead ILIAS will proxy and cache rendered formulae.

## Caveats

It is
* **not** intended as a host for the MathJax client JavaScript library.
* **not** meant to be provided as a publicly accessible service. Do not allow direct access from any untrusted users to services/containers created from this image. You may reverse proxy requests through HTTP (basic) auth.

## Support

* Code on [GitHub](https://github.com/uni-halle/mathjax-docker) ([Issues](https://github.com/uni-halle/mathjax-docker/issues))
* Image on [Docker Hub](https://hub.docker.com/r/unihalle/mathjax)
* Author: Dockerization: Abt. Anwendungssysteme, [ITZ Uni Halle](http://itz.uni-halle.de/); Image includes various open source software.
  See Dockerfile for details.
* Support: As a **university** or **research facility** you might be successful in requesting support through the **[ITZ Helpdesk](mailto:helpdesk@itz.uni-halle.de)** (this can take some time) or contacting the author directly. For **any other entity**, including **companies**, see [my home page](https://wohlpa.de/) for contact details and pricing. You may request hosting, support, more micro services or customizations.
  *Reporting issues and creating pull requests is always welcome and appreciated.*

## Which version/ tag?

There are multiple versions/ tags available under [dockerhub:unihalle/mathjax/tags/](https://hub.docker.com/r/unihalle/mathjax/tags/). Please ensure the tag matches your requirements.

## Basic usage

### Running using Docker only

```
docker run -d \
   --name TestMathJaxServer \
   -p "8003:8003" \
   unihalle/mathjax
```

After the server started, you can test your MathJax server at http://localhost:8003/

### Testing

```
curl \
  -o /tmp/img.png \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"format":"TeX","math":"a + b * \\sqrt{c}","png":true,"width":100}' \
  http://localhost:8003/

xdg-open /tmp/img.png
```

```
curl \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"format":"TeX","math":"a + b * \\sqrt{c}","svg":true,"width":100}' \
  http://localhost:8003/
```

### Using docker-comopse

A comprehensive example on how to get containers/services of this image behind a
reverse-proxy is provided on [github.com/uni-halle/maximapool-docker](https://github.com/uni-halle/maximapool-docker/blob/develop/README.md#using-a-proxy-with-http-basic-auth-and-certificates).

## Configuring ILIAS

Go to `Administration`→`Third Party Software`→`Settings`→`MathJax`

MathJax Settings:

* Enable MathJax on the Server: [x]
* Server Address: If running on the same server, and bound the service to 127.0.0.1, or to all interfaces, `127.0.0.1` should work. If running as a container in the same compose network as ILIAS, your chosen service name, should work. The latter - for instance - allows running the service without exposing it to the public. Note that it might be possible to use HTTP basic auth credentials in this field as part of the URL.
* Timeout: `5` seems to be a sensible default.
* other settings: Your choice.

## FAQ

### Why is PNG rendering so slow and consumes considerable amounts of resources?

MathJax-Server decided, in versions below 1.0 relying on batik SVG generator (Java), and in later versions, to use Phantom.JS.

### Are special scripts supported?

Maybe not, although pull-requests are always welcome.

