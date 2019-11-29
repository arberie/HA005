# Instalimi i Sistemit Operativ te kontenjerit - Imazhi Baze
FROM ubuntu:16.04 as HUGOSETUP
ARG HUGO_VERSION=0.59.1
ENV DOCUMENT_DIR=/hugo-faqja
RUN apt-get update && apt-get upgrade -y \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
           ruby ruby-dev make cmake build-essential bison flex \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/*
RUN gem install --no-document asciidoctor asciidoctor-revealjs \
         rouge asciidoctor-confluence asciidoctor-diagram coderay pygments.rb
# Instalimi i Hugo
ENV HUGO_NAME="hugo_extended_${HUGO_VERSION}_Linux-64bit"
ENV HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_NAME}.deb"
ENV BUILD_DEPS="wget"

RUN apt-get update && \
    apt-get install -y git "${BUILD_DEPS}" && \
    wget "${HUGO_URL}" && \
    apt-get install "./${HUGO_NAME}.deb" && \
    rm -rf "./${HUGO_NAME}.deb" "${HUGO_NAME}" && \
    apt-get remove -y "${BUILD_DEPS}" && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# Kopjo permbajtjen nga follderi aktual ne follderin e faqes se hugos.
COPY ./hugo-faqja /hugo-faqja
WORKDIR /hugo-faqja
# Perdor Hugo per te gjeneruar fajllat statik te faqes.
RUN hugo -v --source=/hugo-faqja --destination=/hugo-faqja/public
# Instalo NGINX dhe vendos fajllat statik te hugos ne follderin html te NGINX.
# Largo faqen e parazgjedhur index.html.
FROM nginx:stable-alpine
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.old
COPY --from=HUGOSETUP /hugo-faqja/public /usr/share/nginx/html
# Konteineri do te ndegjoje ne portin TCP 80
EXPOSE 80

