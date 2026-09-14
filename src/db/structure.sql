--
-- PostgreSQL database dump
--

\restrict e1GM2QdWJc4zE5me0r44uH91JQBf9URh23eW2XYzalRoIG4DBw9MGWccCCoZN7K

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: tsv_trigger_insert_repositories(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tsv_trigger_insert_repositories() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    new.tsv :=
      setweight(to_tsvector('pg_catalog.simple', coalesce(new.name, '')), 'A') ||
      setweight(to_tsvector('pg_catalog.simple', coalesce(new.description, '')), 'B');
    return new;
  end
  $$;


--
-- Name: tsv_trigger_update_repositories(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tsv_trigger_update_repositories() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    SELECT setweight(to_tsvector('pg_catalog.simple', coalesce(r.name, '')), 'A') ||
           setweight(to_tsvector('pg_catalog.simple', coalesce(r.description, '')), 'B') ||
           setweight(to_tsvector('pg_catalog.simple', coalesce((string_agg(tags.name, ' ')), '')), 'C')
      INTO new.tsv
      FROM repositories r
      LEFT JOIN repository_tags ON repository_tags.repository_id = r.id
      LEFT JOIN tags ON tags.id = repository_tags.tag_id
      WHERE r.id = new.id
      GROUP BY r.id;
    return new;
  end
  $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __lustra_metadatas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.__lustra_metadatas (
    metatype text NOT NULL,
    value text NOT NULL
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    provider text NOT NULL,
    uid text NOT NULL,
    raw_json text NOT NULL,
    role integer DEFAULT 0,
    name text,
    email text,
    nickname text,
    first_name text,
    last_name text,
    location text,
    image text,
    phone text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    visitor_id uuid NOT NULL,
    path text NOT NULL,
    route text NOT NULL,
    method text NOT NULL,
    params jsonb DEFAULT '{}'::jsonb NOT NULL,
    referrer text,
    duration_ms bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.languages (
    id bigint NOT NULL,
    name text NOT NULL,
    color text
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: mosquito_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mosquito_metrics (
    id bigint NOT NULL,
    day date NOT NULL,
    queue_name text NOT NULL,
    succeeded bigint DEFAULT 0 NOT NULL,
    failed bigint DEFAULT 0 NOT NULL,
    preempted bigint DEFAULT 0 NOT NULL,
    aborted bigint DEFAULT 0 NOT NULL,
    runtime_ms bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mosquito_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mosquito_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mosquito_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mosquito_metrics_id_seq OWNED BY public.mosquito_metrics.id;


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationships (
    id bigint NOT NULL,
    master_id bigint NOT NULL,
    dependency_id bigint NOT NULL,
    development boolean,
    branch text,
    version text
);


--
-- Name: relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relationships_id_seq OWNED BY public.relationships.id;


--
-- Name: releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.releases (
    id bigint NOT NULL,
    tag_name text NOT NULL,
    provider text NOT NULL,
    provider_id integer,
    name text,
    body text,
    created_at timestamp without time zone NOT NULL,
    published_at timestamp without time zone,
    repository_id bigint NOT NULL
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.releases_id_seq OWNED BY public.releases.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    provider text NOT NULL,
    provider_id integer NOT NULL,
    name public.citext NOT NULL,
    description text,
    shard_yml text,
    readme text,
    changelog text,
    license text,
    last_activity_at timestamp without time zone NOT NULL,
    stars_count integer DEFAULT 0,
    forks_count integer DEFAULT 0,
    open_issues_count integer DEFAULT 0,
    synced_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_on timestamp without time zone DEFAULT now(),
    tsv tsvector,
    user_id bigint NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    ignore boolean DEFAULT false NOT NULL,
    default_branch text DEFAULT 'master'::text NOT NULL,
    fork boolean DEFAULT false NOT NULL
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: repository_forks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_forks (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    fork_id bigint NOT NULL
);


--
-- Name: repository_forks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repository_forks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_forks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repository_forks_id_seq OWNED BY public.repository_forks.id;


--
-- Name: repository_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_languages (
    id bigint NOT NULL,
    language_id bigint NOT NULL,
    repository_id bigint NOT NULL,
    score numeric(5,2)
);


--
-- Name: repository_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repository_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repository_languages_id_seq OWNED BY public.repository_languages.id;


--
-- Name: repository_statistics; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.repository_statistics AS
 SELECT repositories.id AS repository_id,
    COALESCE(dependents.count, (0)::bigint) AS dependents_count,
    COALESCE(dependencies.count, (0)::bigint) AS dependencies_count,
    COALESCE(forks.count, (0)::bigint) AS repository_forks_count
   FROM (((public.repositories
     LEFT JOIN ( SELECT relationships.dependency_id,
            count(*) AS count
           FROM public.relationships
          GROUP BY relationships.dependency_id) dependents ON ((dependents.dependency_id = repositories.id)))
     LEFT JOIN ( SELECT relationships.master_id,
            count(*) AS count
           FROM public.relationships
          GROUP BY relationships.master_id) dependencies ON ((dependencies.master_id = repositories.id)))
     LEFT JOIN ( SELECT repository_forks.parent_id,
            count(*) AS count
           FROM public.repository_forks
          GROUP BY repository_forks.parent_id) forks ON ((forks.parent_id = repositories.id)))
  WITH NO DATA;


--
-- Name: repository_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_tags (
    id bigint NOT NULL,
    tag_id bigint NOT NULL,
    repository_id bigint NOT NULL
);


--
-- Name: repository_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repository_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repository_tags_id_seq OWNED BY public.repository_tags.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name text NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    provider text NOT NULL,
    provider_id integer NOT NULL,
    login public.citext NOT NULL,
    name text,
    kind text NOT NULL,
    avatar_url text,
    created_at timestamp without time zone,
    synced_at timestamp without time zone NOT NULL,
    bio text,
    location text,
    company text,
    email text,
    website text,
    ignore boolean DEFAULT false NOT NULL,
    path text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: visitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visitors (
    id uuid DEFAULT uuidv7() NOT NULL,
    remote_address text NOT NULL,
    user_agent text,
    location jsonb DEFAULT '{}'::jsonb NOT NULL,
    events_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: mosquito_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mosquito_metrics ALTER COLUMN id SET DEFAULT nextval('public.mosquito_metrics_id_seq'::regclass);


--
-- Name: relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships ALTER COLUMN id SET DEFAULT nextval('public.relationships_id_seq'::regclass);


--
-- Name: releases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases ALTER COLUMN id SET DEFAULT nextval('public.releases_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: repository_forks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_forks ALTER COLUMN id SET DEFAULT nextval('public.repository_forks_id_seq'::regclass);


--
-- Name: repository_languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_languages ALTER COLUMN id SET DEFAULT nextval('public.repository_languages_id_seq'::regclass);


--
-- Name: repository_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags ALTER COLUMN id SET DEFAULT nextval('public.repository_tags_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: mosquito_metrics mosquito_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mosquito_metrics
    ADD CONSTRAINT mosquito_metrics_pkey PRIMARY KEY (id);


--
-- Name: relationships relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: repository_forks repository_forks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_forks
    ADD CONSTRAINT repository_forks_pkey PRIMARY KEY (id);


--
-- Name: repository_languages repository_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_languages
    ADD CONSTRAINT repository_languages_pkey PRIMARY KEY (id);


--
-- Name: repository_tags repository_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags
    ADD CONSTRAINT repository_tags_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visitors visitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_pkey PRIMARY KEY (id);


--
-- Name: __clear_metadatas_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX __clear_metadatas_idx ON public.__lustra_metadatas USING btree (metatype, value);


--
-- Name: __lustra_metadatas_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX __lustra_metadatas_idx ON public.__lustra_metadatas USING btree (metatype, value);


--
-- Name: admins_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admins_created_at ON public.admins USING btree (created_at);


--
-- Name: admins_provider_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admins_provider_uid ON public.admins USING btree (provider, uid);


--
-- Name: admins_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admins_updated_at ON public.admins USING btree (updated_at);


--
-- Name: events_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_created_at ON public.events USING btree (created_at);


--
-- Name: events_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_path ON public.events USING btree (path);


--
-- Name: events_route; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_route ON public.events USING btree (route);


--
-- Name: events_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_updated_at ON public.events USING btree (updated_at);


--
-- Name: events_visitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_visitor_id ON public.events USING btree (visitor_id);


--
-- Name: index_repositories_on_synced_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_synced_at ON public.repositories USING btree (synced_at);


--
-- Name: languages_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX languages_name ON public.languages USING btree (name);


--
-- Name: mosquito_metrics_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mosquito_metrics_created_at ON public.mosquito_metrics USING btree (created_at);


--
-- Name: mosquito_metrics_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mosquito_metrics_day ON public.mosquito_metrics USING btree (day);


--
-- Name: mosquito_metrics_queue_name_day; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mosquito_metrics_queue_name_day ON public.mosquito_metrics USING btree (queue_name, day);


--
-- Name: mosquito_metrics_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mosquito_metrics_updated_at ON public.mosquito_metrics USING btree (updated_at);


--
-- Name: relationships_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relationships_dependency_id ON public.relationships USING btree (dependency_id);


--
-- Name: relationships_master_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relationships_master_id ON public.relationships USING btree (master_id);


--
-- Name: relationships_master_id_dependency_id_development; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX relationships_master_id_dependency_id_development ON public.relationships USING btree (master_id, dependency_id, development);


--
-- Name: releases_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX releases_repository_id ON public.releases USING btree (repository_id);


--
-- Name: releases_repository_id_tag_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX releases_repository_id_tag_name ON public.releases USING btree (repository_id, tag_name);


--
-- Name: repositories_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repositories_last_activity_at ON public.repositories USING btree (last_activity_at);


--
-- Name: repositories_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repositories_name ON public.repositories USING btree (name);


--
-- Name: repositories_provider_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repositories_provider_provider_id ON public.repositories USING btree (provider, provider_id);


--
-- Name: repositories_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repositories_tsv ON public.repositories USING gin (tsv);


--
-- Name: repositories_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repositories_user_id ON public.repositories USING btree (user_id);


--
-- Name: repository_forks_fork_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_forks_fork_id ON public.repository_forks USING btree (fork_id);


--
-- Name: repository_forks_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_forks_parent_id ON public.repository_forks USING btree (parent_id);


--
-- Name: repository_forks_parent_id_fork_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repository_forks_parent_id_fork_id ON public.repository_forks USING btree (parent_id, fork_id);


--
-- Name: repository_languages_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_languages_language_id ON public.repository_languages USING btree (language_id);


--
-- Name: repository_languages_language_id_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repository_languages_language_id_repository_id ON public.repository_languages USING btree (language_id, repository_id);


--
-- Name: repository_languages_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_languages_repository_id ON public.repository_languages USING btree (repository_id);


--
-- Name: repository_statistics_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repository_statistics_repository_id ON public.repository_statistics USING btree (repository_id);


--
-- Name: repository_tags_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_tags_repository_id ON public.repository_tags USING btree (repository_id);


--
-- Name: repository_tags_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repository_tags_tag_id ON public.repository_tags USING btree (tag_id);


--
-- Name: repository_tags_tag_id_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repository_tags_tag_id_repository_id ON public.repository_tags USING btree (tag_id, repository_id);


--
-- Name: tags_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_name ON public.tags USING btree (name);


--
-- Name: users_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_login ON public.users USING btree (login);


--
-- Name: users_provider_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_provider_login ON public.users USING btree (provider, login);


--
-- Name: users_provider_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_provider_provider_id ON public.users USING btree (provider, provider_id);


--
-- Name: visitors_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX visitors_created_at ON public.visitors USING btree (created_at);


--
-- Name: visitors_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX visitors_updated_at ON public.visitors USING btree (updated_at);


--
-- Name: repositories tsv_insert_repositories; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsv_insert_repositories BEFORE INSERT ON public.repositories FOR EACH ROW EXECUTE FUNCTION public.tsv_trigger_insert_repositories();


--
-- Name: repositories tsv_update_repositories; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsv_update_repositories BEFORE UPDATE ON public.repositories FOR EACH ROW EXECUTE FUNCTION public.tsv_trigger_update_repositories();


--
-- Name: events events_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id) ON DELETE CASCADE;


--
-- Name: relationships relationships_dependency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_dependency_id_fkey FOREIGN KEY (dependency_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: relationships relationships_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_master_id_fkey FOREIGN KEY (master_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: releases releases_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: repositories repositories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: repository_forks repository_forks_fork_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_forks
    ADD CONSTRAINT repository_forks_fork_id_fkey FOREIGN KEY (fork_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: repository_forks repository_forks_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_forks
    ADD CONSTRAINT repository_forks_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: repository_languages repository_languages_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_languages
    ADD CONSTRAINT repository_languages_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: repository_languages repository_languages_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_languages
    ADD CONSTRAINT repository_languages_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: repository_tags repository_tags_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags
    ADD CONSTRAINT repository_tags_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES public.repositories(id) ON DELETE CASCADE;


--
-- Name: repository_tags repository_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags
    ADD CONSTRAINT repository_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict e1GM2QdWJc4zE5me0r44uH91JQBf9URh23eW2XYzalRoIG4DBw9MGWccCCoZN7K

--
-- PostgreSQL database dump
--

\restrict w4jUtnUlohFyHerYfrAfjNsj0gMN0cVNrqY1tCcv7rQY3LzfWoZGQzwZzde0k4s

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: __lustra_metadatas; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.__lustra_metadatas VALUES ('migration', '-1');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1579040355');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1579103883');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1579191500');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1579874625');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1580767087');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1610645219');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1614607914');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1621937164');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1634391910');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1648817989');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1662110566');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1668943106');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1669032560');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1669543469');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1669546346');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1770374223');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1785151135');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1788438428');
INSERT INTO public.__lustra_metadatas VALUES ('migration', '1789372613');


--
-- PostgreSQL database dump complete
--

\unrestrict w4jUtnUlohFyHerYfrAfjNsj0gMN0cVNrqY1tCcv7rQY3LzfWoZGQzwZzde0k4s

