#!/bin/dash

echo "127.0.0.1     spy.decloak.net" >> /etc/hosts
apt-get install python python-pip python-dev build-essential ruby sqlite3 sqlite python-nfqueue python-gevent golang golang-go apache2 php5 php5-mysql php5-pgsql php5-sqlite php5-odbc openjdk-7-jdk postgresql postgresql-contrib python-twisted ssh iptables libsmi2ldbl libevent-dev libxslt1-dev libxml2-dev wget -y

#database mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password ahead'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ahead'
apt-get -y install mysql-server
echo "create database weblabyrinth;" | mysql -u root --password=ahead
echo "create database webbug;" | mysql -u root --password=ahead
echo "create user 'webbuguser'@'localhost' identified by 'ahead';" | mysql -u root --password=ahead
echo "create user 'weblabyrinthuser'@'localhost' identified by 'ahead';" | mysql -u root --password=ahead
echo "grant all privileges on weblabyrinth.* to 'weblabyrinthuser'@'localhost';" | mysql -u root --password=ahead
echo "grant all privileges on webbug.* to 'webbuguser'@'localhost';" | mysql -u root --password=ahead
echo "create table weblabyrinth.crawlers (crawler_ip TEXT, crawler_rdns TEXT, crawler_useragent TEXT, first_seen INT(11), last_seen INT(11), last_alert INT(11), num_hits INT(11));" | mysql -u root --password=ahead
echo "create table webbug.requests (id TEXT, type TEXT, ip_address TEXT, user_agent TEXT, time INT(11));" | mysql -u root --password=ahead

#database postgres SOON

sudo -u postgres psql -c "CREATE USER decloakuser WITH PASSWORD 'ahead';"

sudo -u postgres psql << EOF
CREATE DATABASE decloak;
\\connect decloak
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: requests; Type: TABLE; Schema: public; Owner: decloakuser; Tablespace:
--

CREATE TABLE requests (
    cip character(32),
    type character varying(16),
    eip character varying(16),
    iip character varying(16),
    dip character varying(16),
    stamp timestamp without time zone DEFAULT now()
);


ALTER TABLE public.requests OWNER TO decloakuser;

--
-- Data for Name: requests; Type: TABLE DATA; Schema: public; Owner: decloakuser
--

COPY requests (cip, type, eip, iip, dip, stamp) FROM stdin;
\.


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--
EOF


#post install www
chown www-data:www-data /var/www -R
#install Conpot

cd /opt
git clone git@github.com:mushorg/conpot.git
cd conpot
python setup.py install

#Install portspoof
cd /opt/portspoof
./configure
make
make install

#post install
cp -r /tmp/AHEAD/webkit/ /var/www/html/
chown www-data:www-data -R /var/www
