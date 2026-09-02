--
-- PostgreSQL database dump
--

\restrict sDS4yplrBh1pvqq63TtewQnZVBkJKK3XPN4tUcIuQY0kGiwzeccwNV7cTQKb4d1

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: parag
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO parag;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: parag
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: diseases; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.diseases (
    disease_id integer NOT NULL,
    disease_name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.diseases OWNER TO parag;

--
-- Name: diseases_disease_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.diseases_disease_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diseases_disease_id_seq OWNER TO parag;

--
-- Name: diseases_disease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.diseases_disease_id_seq OWNED BY public.diseases.disease_id;


--
-- Name: field_reports; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.field_reports (
    report_id integer NOT NULL,
    farmer_id integer,
    animal_species character varying(50),
    photo_url character varying(255),
    symptom_ids integer[],
    latitude numeric(9,6),
    longitude numeric(9,6),
    reported_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.field_reports OWNER TO parag;

--
-- Name: field_reports_report_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.field_reports_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.field_reports_report_id_seq OWNER TO parag;

--
-- Name: field_reports_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.field_reports_report_id_seq OWNED BY public.field_reports.report_id;


--
-- Name: lab_reports; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.lab_reports (
    lab_report_id integer NOT NULL,
    report_id integer NOT NULL,
    lab_technician_id integer,
    confirmed_disease_id integer,
    test_method character varying(100),
    test_results text,
    is_final_truth boolean DEFAULT true,
    used_in_training boolean DEFAULT false,
    verified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lab_reports OWNER TO parag;

--
-- Name: lab_reports_lab_report_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.lab_reports_lab_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lab_reports_lab_report_id_seq OWNER TO parag;

--
-- Name: lab_reports_lab_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.lab_reports_lab_report_id_seq OWNED BY public.lab_reports.lab_report_id;


--
-- Name: model_versions; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.model_versions (
    model_version_id integer NOT NULL,
    model_type character varying(30) NOT NULL,
    version_name character varying(100) NOT NULL,
    model_path text,
    dataset_version character varying(100),
    accuracy numeric(6,4),
    precision_score numeric(6,4),
    recall_score numeric(6,4),
    f1_score numeric(6,4),
    trained_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deployed_at timestamp without time zone,
    is_active boolean DEFAULT false,
    CONSTRAINT model_versions_model_type_check CHECK (((model_type)::text = ANY ((ARRAY['symptom_tabular'::character varying, 'image'::character varying, 'multimodal'::character varying, 'clustering'::character varying])::text[])))
);


ALTER TABLE public.model_versions OWNER TO parag;

--
-- Name: model_versions_model_version_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.model_versions_model_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.model_versions_model_version_id_seq OWNER TO parag;

--
-- Name: model_versions_model_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.model_versions_model_version_id_seq OWNED BY public.model_versions.model_version_id;


--
-- Name: predefined_symptom_map; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.predefined_symptom_map (
    map_id integer NOT NULL,
    symptom_id integer,
    disease_id integer,
    species_id integer,
    symptom_weight numeric(3,2) DEFAULT 1.0,
    is_pathognomonic boolean DEFAULT false
);


ALTER TABLE public.predefined_symptom_map OWNER TO parag;

--
-- Name: predefined_symptom_map_map_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.predefined_symptom_map_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.predefined_symptom_map_map_id_seq OWNER TO parag;

--
-- Name: predefined_symptom_map_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.predefined_symptom_map_map_id_seq OWNED BY public.predefined_symptom_map.map_id;


--
-- Name: species; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.species (
    species_id integer NOT NULL,
    species_name character varying(100) NOT NULL
);


ALTER TABLE public.species OWNER TO parag;

--
-- Name: species_species_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.species_species_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.species_species_id_seq OWNER TO parag;

--
-- Name: species_species_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.species_species_id_seq OWNED BY public.species.species_id;


--
-- Name: symptoms; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.symptoms (
    symptom_id integer NOT NULL,
    symptom_name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.symptoms OWNER TO parag;

--
-- Name: symptoms_symptom_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.symptoms_symptom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.symptoms_symptom_id_seq OWNER TO parag;

--
-- Name: symptoms_symptom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.symptoms_symptom_id_seq OWNED BY public.symptoms.symptom_id;


--
-- Name: triage_results; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.triage_results (
    triage_id integer NOT NULL,
    report_id integer NOT NULL,
    symptom_model_version_id integer,
    image_model_version_id integer,
    multimodal_model_version_id integer,
    symptom_prediction_id integer,
    symptom_confidence numeric(5,4),
    image_prediction_id integer,
    image_confidence numeric(5,4),
    final_prediction_id integer,
    final_confidence numeric(5,4),
    risk_score numeric(5,4),
    risk_level character varying(20),
    processing_method character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.triage_results OWNER TO parag;

--
-- Name: triage_results_triage_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.triage_results_triage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.triage_results_triage_id_seq OWNER TO parag;

--
-- Name: triage_results_triage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.triage_results_triage_id_seq OWNED BY public.triage_results.triage_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    role character varying(50)
);


ALTER TABLE public.users OWNER TO parag;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO parag;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: vet_verifications; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.vet_verifications (
    verification_id integer NOT NULL,
    report_id integer NOT NULL,
    vet_id integer NOT NULL,
    confirmed_disease_id integer,
    is_confirmed boolean DEFAULT false,
    clinical_notes text,
    internal_hemorrhage boolean,
    used_in_training boolean DEFAULT false,
    verified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vet_verifications OWNER TO parag;

--
-- Name: vet_verifications_verification_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.vet_verifications_verification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vet_verifications_verification_id_seq OWNER TO parag;

--
-- Name: vet_verifications_verification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.vet_verifications_verification_id_seq OWNED BY public.vet_verifications.verification_id;


--
-- Name: diseases disease_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.diseases ALTER COLUMN disease_id SET DEFAULT nextval('public.diseases_disease_id_seq'::regclass);


--
-- Name: field_reports report_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.field_reports ALTER COLUMN report_id SET DEFAULT nextval('public.field_reports_report_id_seq'::regclass);


--
-- Name: lab_reports lab_report_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.lab_reports ALTER COLUMN lab_report_id SET DEFAULT nextval('public.lab_reports_lab_report_id_seq'::regclass);


--
-- Name: model_versions model_version_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.model_versions ALTER COLUMN model_version_id SET DEFAULT nextval('public.model_versions_model_version_id_seq'::regclass);


--
-- Name: predefined_symptom_map map_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map ALTER COLUMN map_id SET DEFAULT nextval('public.predefined_symptom_map_map_id_seq'::regclass);


--
-- Name: species species_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.species ALTER COLUMN species_id SET DEFAULT nextval('public.species_species_id_seq'::regclass);


--
-- Name: symptoms symptom_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.symptoms ALTER COLUMN symptom_id SET DEFAULT nextval('public.symptoms_symptom_id_seq'::regclass);


--
-- Name: triage_results triage_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results ALTER COLUMN triage_id SET DEFAULT nextval('public.triage_results_triage_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: vet_verifications verification_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vet_verifications ALTER COLUMN verification_id SET DEFAULT nextval('public.vet_verifications_verification_id_seq'::regclass);


--
-- Data for Name: diseases; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.diseases (disease_id, disease_name, description) FROM stdin;
1	African Swine Fever	Highly contagious viral hemorrhagic disease caused by ASFV (Asfarviridae).
2	Anthrax	Bacterial disease caused by Bacillus anthracis.
3	Avian Influenza	Viral disease caused by Influenza A virus (Orthomyxoviridae); HPAI/LPAI forms.
4	Babesiosis	Tick-borne blood parasite disease, zoonotic.
5	Black Quarter	Bacterial disease causing severe muscle inflammation.
6	Bluetongue	Viral disease of ruminants caused by BTV, transmitted by midges.
7	Trypanosomosis	Parasitic disease caused by Trypanosoma protozoa.
8	Foot and Mouth Disease	Highly contagious viral disease caused by FMDV (Picornaviridae).
9	Swine Fever	Viral disease of pigs with high mortality.
10	Fasciolosis	Parasitic disease caused by Fasciola spp. (liver flukes).
11	Lumpy Skin Disease	Viral disease caused by LSDV (Capripoxvirus, Poxviridae).
12	Sheep and Goat Pox	Viral disease caused by poxvirus affecting sheep and goats.
\.


--
-- Data for Name: field_reports; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.field_reports (report_id, farmer_id, animal_species, photo_url, symptom_ids, latitude, longitude, reported_at) FROM stdin;
1757	174	Cattle	s3://bucket/img.jpg	{1,29,30}	26.013869	92.029125	2026-09-03 00:05:38.376889
1758	201	Goat	s3://bucket/img.jpg	{36,37,38,39}	19.042489	73.040202	2026-09-03 00:05:38.376889
1759	371	Buffalo	s3://bucket/img.jpg	{2,56,57,58,60,61}	18.961661	73.002677	2026-09-03 00:05:38.376889
1760	364	Sheep	s3://bucket/img.jpg	{4,69}	19.049453	73.021838	2026-09-03 00:05:38.376889
1761	80	Goat	s3://bucket/img.jpg	{35,49,50,52,27}	31.024207	75.020331	2026-09-03 00:05:38.376889
1762	311	Cattle	s3://bucket/img.jpg	{47,48,49,52,25,27,30}	30.969121	74.955802	2026-09-03 00:05:38.376889
1763	174	Poultry	s3://bucket/img.jpg	{17,19,21}	18.958486	73.049045	2026-09-03 00:05:38.376889
1764	118	Pig	s3://bucket/img.jpg	{34,53,54,55}	26.008969	92.010832	2026-09-03 00:05:38.376889
1765	73	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.031302	72.985557	2026-09-03 00:05:38.376889
1766	284	Poultry	s3://bucket/img.jpg	{15,17,19,21,22}	30.961671	74.971001	2026-09-03 00:05:38.376889
1767	450	Goat	s3://bucket/img.jpg	{4,69}	30.986429	74.957289	2026-09-03 00:05:38.376889
1768	107	Buffalo	s3://bucket/img.jpg	{64,65,66,68,47,62}	31.018590	74.961355	2026-09-03 00:05:38.376889
1769	329	Sheep	s3://bucket/img.jpg	{4,37,38,40,41,42}	25.997053	91.969888	2026-09-03 00:05:38.376889
1770	150	Buffalo	s3://bucket/img.jpg	{66,62,47}	26.034604	91.980212	2026-09-03 00:05:38.376889
1771	72	Sheep	s3://bucket/img.jpg	{40,42,4,37}	19.009224	72.970808	2026-09-03 00:05:38.376889
1772	185	Cattle	s3://bucket/img.jpg	{33,1,29,30,31}	25.952059	92.030899	2026-09-03 00:05:38.376889
1773	303	Pig	s3://bucket/img.jpg	{2,3,6,7,9,10}	31.030056	74.976888	2026-09-03 00:05:38.376889
1774	259	Sheep	s3://bucket/img.jpg	{1,12,13,14}	26.016513	92.022008	2026-09-03 00:05:38.376889
1775	470	Sheep	s3://bucket/img.jpg	{4,69}	31.031957	75.013256	2026-09-03 00:05:38.376889
1776	410	Sheep	s3://bucket/img.jpg	{2,56,58,59}	26.049356	91.989487	2026-09-03 00:05:38.376889
1777	358	Poultry	s3://bucket/img.jpg	{17,19,22,15}	30.979268	75.017918	2026-09-03 00:05:38.376889
1778	36	Cattle	s3://bucket/img.jpg	{32,1,34,27,31}	12.299738	83.668044	2026-09-03 00:05:38.376889
1779	343	Buffalo	s3://bucket/img.jpg	{65,35,68,16,63}	15.917960	75.629765	2026-09-03 00:05:38.376889
1780	91	Goat	s3://bucket/img.jpg	{35,36,37,40,42,15}	30.976384	74.965900	2026-09-03 00:05:38.376889
1781	30	Buffalo	s3://bucket/img.jpg	{2,43,44}	18.959238	73.025742	2026-09-03 00:05:38.376889
1782	429	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	19.047042	73.045407	2026-09-03 00:05:38.376889
1783	289	Sheep	s3://bucket/img.jpg	{4,69}	26.017366	92.012959	2026-09-03 00:05:38.376889
1784	13	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	29.742300	90.713573	2026-09-03 00:05:38.376889
1785	443	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.986938	91.974529	2026-09-03 00:05:38.376889
1786	138	Goat	s3://bucket/img.jpg	{4,69}	13.234347	93.508566	2026-09-03 00:05:38.376889
1787	193	Cattle	s3://bucket/img.jpg	{2,57,58,59,60,61}	21.301180	68.629772	2026-09-03 00:05:38.376889
1788	119	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	18.963758	72.967380	2026-09-03 00:05:38.376889
1789	32	Poultry	s3://bucket/img.jpg	{17,19,15}	13.969389	93.037121	2026-09-03 00:05:38.376889
1790	55	Cattle	s3://bucket/img.jpg	{2,43,44,45}	19.000337	72.966344	2026-09-03 00:05:38.376889
1791	107	Goat	s3://bucket/img.jpg	{42,4,39}	26.027123	92.025167	2026-09-03 00:05:38.376889
1792	14	Sheep	s3://bucket/img.jpg	{32,34,27,31}	30.973441	74.971633	2026-09-03 00:05:38.376889
1793	381	Cattle	s3://bucket/img.jpg	{24,25,26,23}	10.336165	75.463724	2026-09-03 00:05:38.376889
1794	325	Cattle	s3://bucket/img.jpg	{49,50,27,52}	18.984343	73.028539	2026-09-03 00:05:38.376889
1795	103	Buffalo	s3://bucket/img.jpg	{64,65,67,47}	33.194712	82.379023	2026-09-03 00:05:38.376889
1796	469	Pig	s3://bucket/img.jpg	{3,4,5}	19.001375	72.977354	2026-09-03 00:05:38.376889
1797	47	Goat	s3://bucket/img.jpg	{48,50,52,27,30}	25.975503	92.040444	2026-09-03 00:05:38.376889
1798	350	Goat	s3://bucket/img.jpg	{35,50,27,47}	18.996670	73.030185	2026-09-03 00:05:38.376889
1799	152	Sheep	s3://bucket/img.jpg	{35,4,36,37,38,42}	31.320133	71.743494	2026-09-03 00:05:38.376889
1800	331	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.018425	73.048628	2026-09-03 00:05:38.376889
1801	51	Cattle	s3://bucket/img.jpg	{64,65,68,47,62}	26.027560	91.951735	2026-09-03 00:05:38.376889
1802	326	Pig	s3://bucket/img.jpg	{35,53,54}	13.631279	90.755445	2026-09-03 00:05:38.376889
1803	16	Poultry	s3://bucket/img.jpg	{7,15,16,17,20}	18.970315	73.046394	2026-09-03 00:05:38.376889
1804	387	Cattle	s3://bucket/img.jpg	{66,67,35,68,30}	10.221093	78.413415	2026-09-03 00:05:38.376889
1805	434	Sheep	s3://bucket/img.jpg	{2,57,59,60,61}	26.031184	91.993716	2026-09-03 00:05:38.376889
1806	268	Goat	s3://bucket/img.jpg	{40,36,39}	15.009583	93.016706	2026-09-03 00:05:38.376889
1807	402	Sheep	s3://bucket/img.jpg	{32,1,34,28,30,31}	18.956891	73.010615	2026-09-03 00:05:38.376889
1808	8	Sheep	s3://bucket/img.jpg	{33,27,29,30}	18.983370	72.969623	2026-09-03 00:05:38.376889
1809	349	Sheep	s3://bucket/img.jpg	{56,58,2,60}	30.950516	75.029554	2026-09-03 00:05:38.376889
1810	62	Sheep	s3://bucket/img.jpg	{1,34,30}	30.991401	74.953732	2026-09-03 00:05:38.376889
1811	364	Sheep	s3://bucket/img.jpg	{33,27,29,31}	19.199384	78.964023	2026-09-03 00:05:38.376889
1812	439	Sheep	s3://bucket/img.jpg	{1,12,13,14}	13.637529	74.960085	2026-09-03 00:05:38.376889
1813	426	Pig	s3://bucket/img.jpg	{35,51,53,54,55}	16.262642	84.777111	2026-09-03 00:05:38.376889
1814	40	Sheep	s3://bucket/img.jpg	{2,56,57,58,60,61}	19.031987	73.031691	2026-09-03 00:05:38.376889
1815	259	Poultry	s3://bucket/img.jpg	{15,16,17,18,19}	31.027777	74.954100	2026-09-03 00:05:38.376889
1816	213	Poultry	s3://bucket/img.jpg	{12,20,22,15}	25.965215	91.981661	2026-09-03 00:05:38.376889
1817	45	Sheep	s3://bucket/img.jpg	{42,4,38}	19.031018	73.037506	2026-09-03 00:05:38.376889
1818	157	Buffalo	s3://bucket/img.jpg	{2,43,44,45}	26.046293	91.971296	2026-09-03 00:05:38.376889
1819	440	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.569040	80.566565	2026-09-03 00:05:38.376889
1820	11	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.004790	91.952067	2026-09-03 00:05:38.376889
1821	58	Poultry	s3://bucket/img.jpg	{19,21,15}	26.043252	91.954235	2026-09-03 00:05:38.376889
1822	173	Buffalo	s3://bucket/img.jpg	{2,43,44,45}	26.019352	91.956118	2026-09-03 00:05:38.376889
1823	251	Pig	s3://bucket/img.jpg	{1,2,3,4,6,9}	18.971364	73.017475	2026-09-03 00:05:38.376889
1824	65	Sheep	s3://bucket/img.jpg	{2,16,56,57,58,59}	19.047738	73.003998	2026-09-03 00:05:38.376889
1825	154	Cattle	s3://bucket/img.jpg	{65,35,68,47}	34.226149	86.549398	2026-09-03 00:05:38.376889
1826	111	Pig	s3://bucket/img.jpg	{35,53,54}	25.956497	91.960691	2026-09-03 00:05:38.376889
1827	389	Pig	s3://bucket/img.jpg	{35,53,55}	26.037758	91.975066	2026-09-03 00:05:38.376889
1828	378	Cattle	s3://bucket/img.jpg	{1,43,29,30,31}	26.019337	92.049689	2026-09-03 00:05:38.376889
1829	497	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.950352	73.034986	2026-09-03 00:05:38.376889
1830	340	Poultry	s3://bucket/img.jpg	{21,6,15}	25.983000	91.995365	2026-09-03 00:05:38.376889
1831	448	Cattle	s3://bucket/img.jpg	{25,26,23}	25.953658	91.958148	2026-09-03 00:05:38.376889
1832	140	Sheep	s3://bucket/img.jpg	{32,1,33}	15.696537	89.854022	2026-09-03 00:05:38.376889
1833	330	Sheep	s3://bucket/img.jpg	{56,57,58,59,60,61}	19.042303	72.998532	2026-09-03 00:05:38.376889
1834	68	Pig	s3://bucket/img.jpg	{35,47,48,49,52,27}	26.971051	74.904257	2026-09-03 00:05:38.376889
1835	199	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.007137	91.973474	2026-09-03 00:05:38.376889
1836	358	Cattle	s3://bucket/img.jpg	{24,25,23}	18.975752	73.026611	2026-09-03 00:05:38.376889
1837	250	Buffalo	s3://bucket/img.jpg	{2,56,57,58,60}	31.035074	75.032774	2026-09-03 00:05:38.376889
1838	364	Cattle	s3://bucket/img.jpg	{1,12,13}	30.970248	74.961134	2026-09-03 00:05:38.376889
1839	358	Goat	s3://bucket/img.jpg	{41,4,37,38}	31.036926	74.986961	2026-09-03 00:05:38.376889
1840	427	Cattle	s3://bucket/img.jpg	{32,33,34,1,27,30}	20.432185	78.859646	2026-09-03 00:05:38.376889
1841	412	Cattle	s3://bucket/img.jpg	{2,44,45}	26.036619	91.962741	2026-09-03 00:05:38.376889
1842	244	Sheep	s3://bucket/img.jpg	{1,12,13,14}	34.437789	94.403108	2026-09-03 00:05:38.376889
1843	151	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.231109	74.001192	2026-09-03 00:05:38.376889
1844	34	Poultry	s3://bucket/img.jpg	{17,18,12,22}	25.977792	91.962227	2026-09-03 00:05:38.376889
1845	253	Goat	s3://bucket/img.jpg	{1,12,13,14}	18.998764	72.976056	2026-09-03 00:05:38.376889
1846	124	Buffalo	s3://bucket/img.jpg	{64,35,67,68,62}	9.494094	82.332973	2026-09-03 00:05:38.376889
1847	366	Sheep	s3://bucket/img.jpg	{41,42,4,39}	27.116066	85.828116	2026-09-03 00:05:38.376889
1848	367	Poultry	s3://bucket/img.jpg	{17,12,21,22}	30.989859	75.012527	2026-09-03 00:05:38.376889
1849	480	Buffalo	s3://bucket/img.jpg	{56,57,58,59,60,61}	33.189477	80.109229	2026-09-03 00:05:38.376889
1850	393	Pig	s3://bucket/img.jpg	{2,5,6,7,11}	31.256618	70.103027	2026-09-03 00:05:38.376889
1851	35	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.952741	72.974486	2026-09-03 00:05:38.376889
1852	302	Sheep	s3://bucket/img.jpg	{1,12,14}	25.972957	91.964387	2026-09-03 00:05:38.376889
1853	51	Pig	s3://bucket/img.jpg	{1,2,8,9,10}	10.856932	91.505536	2026-09-03 00:05:38.376889
1854	391	Sheep	s3://bucket/img.jpg	{64,1,33,29,31}	19.028490	72.957892	2026-09-03 00:05:38.376889
1855	368	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	15.712322	77.382787	2026-09-03 00:05:38.376889
1856	423	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	18.968930	73.042004	2026-09-03 00:05:38.376889
1857	327	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.968135	91.999105	2026-09-03 00:05:38.376889
1858	182	Sheep	s3://bucket/img.jpg	{2,57,58,59,60,61}	26.042190	92.038686	2026-09-03 00:05:38.376889
1859	11	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.979672	92.006927	2026-09-03 00:05:38.376889
1860	314	Cattle	s3://bucket/img.jpg	{24,25,26,23}	20.063047	87.587410	2026-09-03 00:05:38.376889
1861	351	Sheep	s3://bucket/img.jpg	{58,51,60,61}	25.976095	91.972389	2026-09-03 00:05:38.376889
1862	3	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.965893	74.986932	2026-09-03 00:05:38.376889
1863	405	Goat	s3://bucket/img.jpg	{40,41,39}	29.081191	89.149443	2026-09-03 00:05:38.376889
1864	388	Cattle	s3://bucket/img.jpg	{57,58,59,60}	19.008466	72.980168	2026-09-03 00:05:38.376889
1865	93	Pig	s3://bucket/img.jpg	{35,53,54,55}	11.797077	84.651844	2026-09-03 00:05:38.376889
1866	345	Poultry	s3://bucket/img.jpg	{21,12,20,22}	26.003803	92.036818	2026-09-03 00:05:38.376889
1867	97	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	34.864453	91.411153	2026-09-03 00:05:38.376889
1868	494	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.021647	73.036589	2026-09-03 00:05:38.376889
1869	384	Goat	s3://bucket/img.jpg	{41,42,39}	25.958674	92.036717	2026-09-03 00:05:38.376889
1870	113	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	26.005132	92.013249	2026-09-03 00:05:38.376889
1871	174	Cattle	s3://bucket/img.jpg	{33,34,27,28,29,31}	19.030687	72.996037	2026-09-03 00:05:38.376889
1872	24	Cattle	s3://bucket/img.jpg	{1,12,13,14}	31.036021	74.971361	2026-09-03 00:05:38.376889
1873	468	Poultry	s3://bucket/img.jpg	{19,20,6}	31.011229	75.019797	2026-09-03 00:05:38.376889
1874	93	Poultry	s3://bucket/img.jpg	{15,17,18,20,21,22}	31.014471	74.962711	2026-09-03 00:05:38.376889
1875	26	Sheep	s3://bucket/img.jpg	{32,33,34,1,28,30}	19.030390	72.994173	2026-09-03 00:05:38.376889
1876	241	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	31.049875	75.017970	2026-09-03 00:05:38.376889
1877	28	Buffalo	s3://bucket/img.jpg	{2,34,43,44,45,46}	18.985655	73.022751	2026-09-03 00:05:38.376889
1878	135	Sheep	s3://bucket/img.jpg	{56,57,60}	30.959890	75.028933	2026-09-03 00:05:38.376889
1879	199	Pig	s3://bucket/img.jpg	{3,4,5,6,7,10}	12.035919	77.929886	2026-09-03 00:05:38.376889
1880	216	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	26.003677	91.957400	2026-09-03 00:05:38.376889
1881	224	Goat	s3://bucket/img.jpg	{4,69}	25.602991	85.896491	2026-09-03 00:05:38.376889
1882	177	Goat	s3://bucket/img.jpg	{4,69}	28.338975	78.924456	2026-09-03 00:05:38.376889
1883	388	Sheep	s3://bucket/img.jpg	{35,47,48,51,27,30}	30.997555	74.960439	2026-09-03 00:05:38.376889
1884	87	Poultry	s3://bucket/img.jpg	{6,21,22,15}	19.012310	72.997604	2026-09-03 00:05:38.376889
1885	471	Goat	s3://bucket/img.jpg	{35,48,51,52,27}	19.047280	73.040782	2026-09-03 00:05:38.376889
1886	30	Sheep	s3://bucket/img.jpg	{1,12,13}	30.962346	75.016524	2026-09-03 00:05:38.376889
1887	287	Cattle	s3://bucket/img.jpg	{27,51,48,35}	18.988462	72.981992	2026-09-03 00:05:38.376889
1888	51	Cattle	s3://bucket/img.jpg	{32,34,29,31}	18.985556	72.970541	2026-09-03 00:05:38.376889
1889	179	Pig	s3://bucket/img.jpg	{16,35,54,55}	25.950604	92.012907	2026-09-03 00:05:38.376889
1890	246	Pig	s3://bucket/img.jpg	{35,53,54,55}	25.959659	92.045358	2026-09-03 00:05:38.376889
1891	406	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	30.965387	75.004462	2026-09-03 00:05:38.376889
1892	114	Poultry	s3://bucket/img.jpg	{12,18,19,20,21}	26.020433	92.028266	2026-09-03 00:05:38.376889
1893	202	Sheep	s3://bucket/img.jpg	{4,69}	25.958237	91.991572	2026-09-03 00:05:38.376889
1894	467	Pig	s3://bucket/img.jpg	{35,53,54,55}	27.444332	84.437866	2026-09-03 00:05:38.376889
1895	13	Sheep	s3://bucket/img.jpg	{4,69}	18.998582	73.022287	2026-09-03 00:05:38.376889
1896	174	Cattle	s3://bucket/img.jpg	{1,12,14}	17.287295	94.616033	2026-09-03 00:05:38.376889
1897	12	Cattle	s3://bucket/img.jpg	{66,67,68,62,63}	10.138732	94.399262	2026-09-03 00:05:38.376889
1898	359	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.034653	74.978980	2026-09-03 00:05:38.376889
1899	367	Sheep	s3://bucket/img.jpg	{27,35,52}	30.973795	75.035640	2026-09-03 00:05:38.376889
1900	380	Buffalo	s3://bucket/img.jpg	{64,35,67,16}	30.998344	74.992214	2026-09-03 00:05:38.376889
1901	133	Buffalo	s3://bucket/img.jpg	{66,67,35,62,63}	19.031390	73.047570	2026-09-03 00:05:38.376889
1902	481	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.041168	73.037655	2026-09-03 00:05:38.376889
1903	207	Cattle	s3://bucket/img.jpg	{24,25,26,23}	16.765663	77.291770	2026-09-03 00:05:38.376889
1904	325	Poultry	s3://bucket/img.jpg	{6,12,15,16,17,22,60}	26.046853	91.980038	2026-09-03 00:05:38.376889
1905	438	Sheep	s3://bucket/img.jpg	{4,69}	26.045971	91.989888	2026-09-03 00:05:38.376889
1906	5	Goat	s3://bucket/img.jpg	{4,69}	18.985214	73.008871	2026-09-03 00:05:38.376889
1907	261	Goat	s3://bucket/img.jpg	{4,69}	33.508560	73.491621	2026-09-03 00:05:38.376889
1908	71	Goat	s3://bucket/img.jpg	{1,12,13,14}	24.986226	69.383691	2026-09-03 00:05:38.376889
1909	434	Sheep	s3://bucket/img.jpg	{4,36,39,41,42}	30.964684	74.952071	2026-09-03 00:05:38.376889
1910	485	Poultry	s3://bucket/img.jpg	{6,12,15,16,17,21}	30.992599	75.026404	2026-09-03 00:05:38.376889
1911	318	Cattle	s3://bucket/img.jpg	{34,27,28,29,30,31}	10.571465	89.374930	2026-09-03 00:05:38.376889
1912	21	Pig	s3://bucket/img.jpg	{2,3,4,5,8,10}	31.003279	74.950880	2026-09-03 00:05:38.376889
1913	395	Sheep	s3://bucket/img.jpg	{1,12,13}	31.028554	75.012369	2026-09-03 00:05:38.376889
1914	396	Sheep	s3://bucket/img.jpg	{1,12,13,14}	30.963714	75.004087	2026-09-03 00:05:38.376889
1915	307	Sheep	s3://bucket/img.jpg	{49,35,51}	26.043909	92.021051	2026-09-03 00:05:38.376889
1916	262	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.031538	72.995023	2026-09-03 00:05:38.376889
1917	118	Goat	s3://bucket/img.jpg	{35,49,50,51,52,27}	25.961731	91.975277	2026-09-03 00:05:38.376889
1918	160	Cattle	s3://bucket/img.jpg	{1,34,33,30,31}	19.019187	73.001322	2026-09-03 00:05:38.376889
1919	380	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46,14}	17.261463	75.017925	2026-09-03 00:05:38.376889
1920	128	Sheep	s3://bucket/img.jpg	{33,34,1,29,31}	25.986165	92.005566	2026-09-03 00:05:38.376889
1921	159	Cattle	s3://bucket/img.jpg	{2,43,44,45}	19.013291	72.959572	2026-09-03 00:05:38.376889
1922	225	Cattle	s3://bucket/img.jpg	{32,1,34,29}	26.028918	91.997406	2026-09-03 00:05:38.376889
1923	413	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.991305	74.985577	2026-09-03 00:05:38.376889
1924	351	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	11.304103	88.538644	2026-09-03 00:05:38.376889
1925	106	Pig	s3://bucket/img.jpg	{35,27,51,47}	19.007825	73.016164	2026-09-03 00:05:38.376889
1926	426	Pig	s3://bucket/img.jpg	{47,49,51,52,31}	18.989610	72.960939	2026-09-03 00:05:38.376889
1927	198	Sheep	s3://bucket/img.jpg	{1,34,33,27,29}	19.011238	72.961425	2026-09-03 00:05:38.376889
1928	173	Cattle	s3://bucket/img.jpg	{33,27,29}	28.917461	88.480270	2026-09-03 00:05:38.376889
1929	282	Sheep	s3://bucket/img.jpg	{4,69}	31.023109	74.963578	2026-09-03 00:05:38.376889
1930	448	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.031883	75.040334	2026-09-03 00:05:38.376889
1931	340	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.962584	75.027753	2026-09-03 00:05:38.376889
1932	1	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.996072	91.975071	2026-09-03 00:05:38.376889
1933	162	Poultry	s3://bucket/img.jpg	{12,15,16,17,18}	30.967547	75.036765	2026-09-03 00:05:38.376889
1934	170	Cattle	s3://bucket/img.jpg	{48,50,51,30}	31.048669	75.018044	2026-09-03 00:05:38.376889
1935	352	Poultry	s3://bucket/img.jpg	{19,12,21}	19.000725	73.003987	2026-09-03 00:05:38.376889
1936	478	Sheep	s3://bucket/img.jpg	{58,59,61}	12.007939	82.320981	2026-09-03 00:05:38.376889
1937	321	Pig	s3://bucket/img.jpg	{48,27,30}	19.009816	73.036539	2026-09-03 00:05:38.376889
1938	477	Cattle	s3://bucket/img.jpg	{25,26,23}	31.233163	79.063057	2026-09-03 00:05:38.376889
1939	259	Sheep	s3://bucket/img.jpg	{56,58,2,60}	31.017671	74.974587	2026-09-03 00:05:38.376889
1940	97	Cattle	s3://bucket/img.jpg	{1,12,13,14,52}	10.185379	87.559117	2026-09-03 00:05:38.376889
1941	16	Cattle	s3://bucket/img.jpg	{2,59,60}	19.013169	72.980535	2026-09-03 00:05:38.376889
1942	202	Cattle	s3://bucket/img.jpg	{1,12,14}	19.032964	72.994154	2026-09-03 00:05:38.376889
1943	357	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.969370	92.048954	2026-09-03 00:05:38.376889
1944	291	Sheep	s3://bucket/img.jpg	{33,38,27,29,30}	29.018736	79.263087	2026-09-03 00:05:38.376889
1945	340	Sheep	s3://bucket/img.jpg	{47,49,51,52,27}	23.131760	94.004838	2026-09-03 00:05:38.376889
1946	35	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.904505	90.593778	2026-09-03 00:05:38.376889
1947	123	Sheep	s3://bucket/img.jpg	{1,27,30}	16.962404	75.662960	2026-09-03 00:05:38.376889
1948	313	Buffalo	s3://bucket/img.jpg	{43,44,46}	25.979073	91.985152	2026-09-03 00:05:38.376889
1949	120	Pig	s3://bucket/img.jpg	{35,17,53,54,55}	31.002172	74.968702	2026-09-03 00:05:38.376889
1950	34	Buffalo	s3://bucket/img.jpg	{65,68,47}	25.953410	92.047386	2026-09-03 00:05:38.376889
1951	70	Buffalo	s3://bucket/img.jpg	{64,67,35,68,62}	23.935807	79.961304	2026-09-03 00:05:38.376889
1952	489	Cattle	s3://bucket/img.jpg	{24,25,26}	8.321413	70.375377	2026-09-03 00:05:38.376889
1953	279	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	19.007614	72.980688	2026-09-03 00:05:38.376889
1954	141	Goat	s3://bucket/img.jpg	{41,36,4}	19.030051	72.984205	2026-09-03 00:05:38.376889
1955	285	Cattle	s3://bucket/img.jpg	{68,47,62,63}	22.917019	87.706114	2026-09-03 00:05:38.376889
1956	467	Buffalo	s3://bucket/img.jpg	{65,35,68,47,62,63}	31.038331	75.005574	2026-09-03 00:05:38.376889
1957	62	Sheep	s3://bucket/img.jpg	{4,69}	20.699302	86.633665	2026-09-03 00:05:38.376889
1958	125	Sheep	s3://bucket/img.jpg	{4,69}	19.039236	73.019352	2026-09-03 00:05:38.376889
1959	82	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.045508	75.003532	2026-09-03 00:05:38.376889
1960	69	Pig	s3://bucket/img.jpg	{8,1,2,10}	31.002792	74.977371	2026-09-03 00:05:38.376889
1961	225	Sheep	s3://bucket/img.jpg	{4,69}	31.018426	74.990537	2026-09-03 00:05:38.376889
1962	348	Sheep	s3://bucket/img.jpg	{56,57,37,61}	19.042363	73.043481	2026-09-03 00:05:38.376889
1963	160	Cattle	s3://bucket/img.jpg	{2,58,60,61}	26.015851	91.997685	2026-09-03 00:05:38.376889
1964	288	Pig	s3://bucket/img.jpg	{1,3,5,8,10,11}	18.970750	73.048249	2026-09-03 00:05:38.376889
1965	388	Pig	s3://bucket/img.jpg	{35,53,54,55}	14.467225	94.538159	2026-09-03 00:05:38.376889
1966	122	Pig	s3://bucket/img.jpg	{9,3,6}	18.965149	72.969430	2026-09-03 00:05:38.376889
1967	188	Cattle	s3://bucket/img.jpg	{65,23,24,25,26}	26.023705	91.958139	2026-09-03 00:05:38.376889
1968	199	Buffalo	s3://bucket/img.jpg	{2,58,59,60,61}	18.973777	73.015277	2026-09-03 00:05:38.376889
1969	465	Sheep	s3://bucket/img.jpg	{4,69}	18.974266	73.007573	2026-09-03 00:05:38.376889
1970	239	Goat	s3://bucket/img.jpg	{41,35,36}	25.951666	92.031487	2026-09-03 00:05:38.376889
1971	253	Cattle	s3://bucket/img.jpg	{35,48,49,50,52,30}	30.717542	86.391101	2026-09-03 00:05:38.376889
1972	222	Cattle	s3://bucket/img.jpg	{2,43,45,46}	19.040334	72.952150	2026-09-03 00:05:38.376889
1973	105	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.985695	91.979663	2026-09-03 00:05:38.376889
1974	247	Pig	s3://bucket/img.jpg	{35,53,54,55}	21.547695	78.245749	2026-09-03 00:05:38.376889
1975	80	Sheep	s3://bucket/img.jpg	{32,33,28,29,30}	25.974328	91.960656	2026-09-03 00:05:38.376889
1976	182	Cattle	s3://bucket/img.jpg	{12,13,14}	25.550760	74.738508	2026-09-03 00:05:38.376889
1977	31	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	18.992561	72.957678	2026-09-03 00:05:38.376889
1978	433	Goat	s3://bucket/img.jpg	{1,12,13,14}	19.137934	71.568475	2026-09-03 00:05:38.376889
1979	490	Cattle	s3://bucket/img.jpg	{64,68,63,47}	18.963383	72.956186	2026-09-03 00:05:38.376889
1980	134	Sheep	s3://bucket/img.jpg	{1,12,13,14}	26.070934	76.154900	2026-09-03 00:05:38.376889
1981	413	Buffalo	s3://bucket/img.jpg	{64,66,68,47}	25.972012	92.040455	2026-09-03 00:05:38.376889
1982	472	Poultry	s3://bucket/img.jpg	{17,19,20,15}	11.436068	78.964665	2026-09-03 00:05:38.376889
1983	200	Sheep	s3://bucket/img.jpg	{35,36,4,38}	33.129329	86.656340	2026-09-03 00:05:38.376889
1984	303	Goat	s3://bucket/img.jpg	{4,69}	19.026863	73.038091	2026-09-03 00:05:38.376889
1985	226	Sheep	s3://bucket/img.jpg	{4,69}	26.013433	91.964838	2026-09-03 00:05:38.376889
1986	261	Sheep	s3://bucket/img.jpg	{1,33,27,28,29,30}	19.035775	72.996939	2026-09-03 00:05:38.376889
1987	358	Poultry	s3://bucket/img.jpg	{17,18,15}	19.039912	73.010351	2026-09-03 00:05:38.376889
1988	344	Sheep	s3://bucket/img.jpg	{32,1,33,28,29,31}	30.985836	75.018337	2026-09-03 00:05:38.376889
1989	115	Sheep	s3://bucket/img.jpg	{33,34,28,29,30,31}	25.960452	91.988471	2026-09-03 00:05:38.376889
1990	86	Goat	s3://bucket/img.jpg	{49,50,35,54}	30.982021	75.003642	2026-09-03 00:05:38.376889
1991	444	Sheep	s3://bucket/img.jpg	{32,1,34,27}	11.220567	84.947540	2026-09-03 00:05:38.376889
1992	437	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.981855	92.038113	2026-09-03 00:05:38.376889
1993	276	Pig	s3://bucket/img.jpg	{2,4,7}	19.004171	73.034973	2026-09-03 00:05:38.376889
1994	20	Sheep	s3://bucket/img.jpg	{1,12,13,14}	22.019055	74.734714	2026-09-03 00:05:38.376889
1995	24	Cattle	s3://bucket/img.jpg	{24,26,23}	30.961417	74.998660	2026-09-03 00:05:38.376889
1996	314	Buffalo	s3://bucket/img.jpg	{64,65,66,67,68}	25.959406	91.968642	2026-09-03 00:05:38.376889
1997	77	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.046804	75.025487	2026-09-03 00:05:38.376889
1998	256	Pig	s3://bucket/img.jpg	{35,53,54,55}	21.387943	85.989117	2026-09-03 00:05:38.376889
1999	440	Goat	s3://bucket/img.jpg	{4,69}	18.969479	73.023522	2026-09-03 00:05:38.376889
2000	435	Sheep	s3://bucket/img.jpg	{57,58,60,61}	26.041712	91.967007	2026-09-03 00:05:38.376889
2001	373	Cattle	s3://bucket/img.jpg	{24,25,23}	19.023932	72.950022	2026-09-03 00:05:38.376889
2002	479	Pig	s3://bucket/img.jpg	{1,2,3,4,5,8}	28.551562	74.094249	2026-09-03 00:05:38.376889
2003	235	Sheep	s3://bucket/img.jpg	{4,69}	14.756043	88.025751	2026-09-03 00:05:38.376889
2004	123	Cattle	s3://bucket/img.jpg	{35,47,48,49,52,30}	25.982279	91.993479	2026-09-03 00:05:38.376889
2005	413	Pig	s3://bucket/img.jpg	{35,53,54}	19.041316	73.016606	2026-09-03 00:05:38.376889
2006	397	Sheep	s3://bucket/img.jpg	{40,35,37,38}	18.997103	72.998267	2026-09-03 00:05:38.376889
2007	428	Sheep	s3://bucket/img.jpg	{32,27,28,31}	25.986612	92.048032	2026-09-03 00:05:38.376889
2008	5	Sheep	s3://bucket/img.jpg	{47,49,50,27,30}	25.963457	91.958445	2026-09-03 00:05:38.376889
2009	159	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.013179	75.017529	2026-09-03 00:05:38.376889
2010	60	Pig	s3://bucket/img.jpg	{35,53,55}	19.028005	72.990178	2026-09-03 00:05:38.376889
2011	362	Goat	s3://bucket/img.jpg	{1,12,13,14}	26.036394	91.959248	2026-09-03 00:05:38.376889
2012	197	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.992075	72.965714	2026-09-03 00:05:38.376889
2013	88	Cattle	s3://bucket/img.jpg	{24,25,26,23}	22.646997	71.802369	2026-09-03 00:05:38.376889
2014	48	Goat	s3://bucket/img.jpg	{4,69}	15.784481	82.622517	2026-09-03 00:05:38.376889
2015	215	Cattle	s3://bucket/img.jpg	{24,25,23}	31.000834	75.014156	2026-09-03 00:05:38.376889
2016	438	Goat	s3://bucket/img.jpg	{4,69}	33.248509	70.810657	2026-09-03 00:05:38.376889
2017	132	Sheep	s3://bucket/img.jpg	{2,56,57,58,61}	26.004191	91.971080	2026-09-03 00:05:38.376889
2018	145	Pig	s3://bucket/img.jpg	{1,3,5,7,9}	19.044650	72.994442	2026-09-03 00:05:38.376889
2019	360	Sheep	s3://bucket/img.jpg	{56,4,69}	31.019960	75.034537	2026-09-03 00:05:38.376889
2020	482	Goat	s3://bucket/img.jpg	{4,69}	19.032465	73.002938	2026-09-03 00:05:38.376889
2021	19	Sheep	s3://bucket/img.jpg	{35,47,48,51,27,30}	29.641338	92.147942	2026-09-03 00:05:38.376889
2022	108	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.002230	92.007919	2026-09-03 00:05:38.376889
2023	11	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.989170	75.019888	2026-09-03 00:05:38.376889
2024	315	Cattle	s3://bucket/img.jpg	{32,1,27,28}	13.883147	79.326545	2026-09-03 00:05:38.376889
2025	440	Buffalo	s3://bucket/img.jpg	{43,45,46}	30.954549	74.986424	2026-09-03 00:05:38.376889
2026	283	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.994590	72.979492	2026-09-03 00:05:38.376889
2027	418	Sheep	s3://bucket/img.jpg	{4,69}	28.883874	85.435250	2026-09-03 00:05:38.376889
2028	228	Sheep	s3://bucket/img.jpg	{4,69}	30.970157	74.977978	2026-09-03 00:05:38.376889
2029	390	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.999542	92.015540	2026-09-03 00:05:38.376889
2030	300	Poultry	s3://bucket/img.jpg	{12,15,16,17,19,20}	17.212772	68.762490	2026-09-03 00:05:38.376889
2031	8	Buffalo	s3://bucket/img.jpg	{65,67,68,47,63}	18.985976	72.983037	2026-09-03 00:05:38.376889
2032	448	Poultry	s3://bucket/img.jpg	{6,12,17,18,19}	26.024309	92.042745	2026-09-03 00:05:38.376889
2033	434	Pig	s3://bucket/img.jpg	{35,53,54,55,57}	26.021279	92.013843	2026-09-03 00:05:38.376889
2034	339	Poultry	s3://bucket/img.jpg	{17,18,20,21,22}	11.934212	68.417641	2026-09-03 00:05:38.376889
2035	104	Sheep	s3://bucket/img.jpg	{12,13,14}	18.963421	72.963516	2026-09-03 00:05:38.376889
2036	81	Sheep	s3://bucket/img.jpg	{1,34,27,29}	15.013980	87.065242	2026-09-03 00:05:38.376889
2037	202	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.953267	73.007924	2026-09-03 00:05:38.376889
2038	43	Cattle	s3://bucket/img.jpg	{24,25,26}	19.002215	73.022840	2026-09-03 00:05:38.376889
2039	340	Goat	s3://bucket/img.jpg	{1,12,13,14}	31.006632	75.036622	2026-09-03 00:05:38.376889
2040	51	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	30.988312	75.002249	2026-09-03 00:05:38.376889
2041	393	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.038990	73.036709	2026-09-03 00:05:38.376889
2042	326	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.991076	92.035035	2026-09-03 00:05:38.376889
2043	368	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.975301	72.992259	2026-09-03 00:05:38.376889
2044	351	Buffalo	s3://bucket/img.jpg	{65,66,68,47}	31.019030	74.986568	2026-09-03 00:05:38.376889
2045	83	Sheep	s3://bucket/img.jpg	{33,34,1,27,28}	25.956238	92.041040	2026-09-03 00:05:38.376889
2046	146	Cattle	s3://bucket/img.jpg	{35,49,50,52,30}	18.054911	80.588887	2026-09-03 00:05:38.376889
2047	277	Goat	s3://bucket/img.jpg	{1,12,13,14}	25.988412	91.961398	2026-09-03 00:05:38.376889
2048	166	Sheep	s3://bucket/img.jpg	{48,35,52}	18.984420	72.976790	2026-09-03 00:05:38.376889
2049	391	Buffalo	s3://bucket/img.jpg	{64,65,68,47,62,63}	18.958221	72.971489	2026-09-03 00:05:38.376889
2050	126	Pig	s3://bucket/img.jpg	{2,10,5,6}	25.986755	92.022679	2026-09-03 00:05:38.376889
2051	388	Pig	s3://bucket/img.jpg	{35,53,55}	19.021050	72.986121	2026-09-03 00:05:38.376889
2052	217	Sheep	s3://bucket/img.jpg	{10,49,50,52,27,30}	19.024898	73.022272	2026-09-03 00:05:38.376889
2053	407	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.976606	92.001971	2026-09-03 00:05:38.376889
2054	254	Sheep	s3://bucket/img.jpg	{4,69}	26.041189	92.036571	2026-09-03 00:05:38.376889
2055	222	Cattle	s3://bucket/img.jpg	{32,33,34,28,29,31}	31.008709	75.033258	2026-09-03 00:05:38.376889
2056	421	Sheep	s3://bucket/img.jpg	{57,59,60,61}	31.004722	75.007647	2026-09-03 00:05:38.376889
2057	256	Cattle	s3://bucket/img.jpg	{65,66,35,47,62}	31.331344	85.991675	2026-09-03 00:05:38.376889
2058	370	Cattle	s3://bucket/img.jpg	{1,12,13,7}	26.040714	91.981057	2026-09-03 00:05:38.376889
2059	410	Goat	s3://bucket/img.jpg	{4,69}	11.217289	73.461662	2026-09-03 00:05:38.376889
2060	160	Goat	s3://bucket/img.jpg	{1,12,13,14}	25.952292	91.951124	2026-09-03 00:05:38.376889
2061	464	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	29.202774	69.396713	2026-09-03 00:05:38.376889
2062	423	Sheep	s3://bucket/img.jpg	{36,4,38,39,40,42}	25.994921	91.990553	2026-09-03 00:05:38.376889
2063	261	Buffalo	s3://bucket/img.jpg	{64,35,47}	18.973870	72.961235	2026-09-03 00:05:38.376889
2064	280	Sheep	s3://bucket/img.jpg	{2,56,57,58,59,60}	31.031366	75.014563	2026-09-03 00:05:38.376889
2065	360	Pig	s3://bucket/img.jpg	{1,2,4,5,9,10}	26.014388	92.017927	2026-09-03 00:05:38.376889
2066	229	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.044977	72.963183	2026-09-03 00:05:38.376889
2067	472	Sheep	s3://bucket/img.jpg	{1,12,13,14}	25.959593	91.958293	2026-09-03 00:05:38.376889
2068	423	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.012863	91.970086	2026-09-03 00:05:38.376889
2069	259	Goat	s3://bucket/img.jpg	{41,42,36,39}	18.990571	73.031190	2026-09-03 00:05:38.376889
2070	299	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.004588	73.016355	2026-09-03 00:05:38.376889
2071	443	Pig	s3://bucket/img.jpg	{8,10,4,7}	18.964350	72.994744	2026-09-03 00:05:38.376889
2072	14	Goat	s3://bucket/img.jpg	{1,12,13,14}	31.034055	75.023245	2026-09-03 00:05:38.376889
2073	248	Sheep	s3://bucket/img.jpg	{33,28,30,31}	25.985612	91.988024	2026-09-03 00:05:38.376889
2074	86	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.042850	92.036110	2026-09-03 00:05:38.376889
2075	48	Pig	s3://bucket/img.jpg	{1,2,4,8,9}	30.994110	74.968697	2026-09-03 00:05:38.376889
2076	397	Sheep	s3://bucket/img.jpg	{32,34,27}	33.920914	71.482191	2026-09-03 00:05:38.376889
2077	484	Sheep	s3://bucket/img.jpg	{40,37,39}	30.953422	75.041223	2026-09-03 00:05:38.376889
2078	23	Sheep	s3://bucket/img.jpg	{1,12,13,14}	26.011912	91.967713	2026-09-03 00:05:38.376889
2079	437	Goat	s3://bucket/img.jpg	{42,36,39}	17.745880	86.477111	2026-09-03 00:05:38.376889
2080	428	Pig	s3://bucket/img.jpg	{35,53,54,55}	25.996709	91.968606	2026-09-03 00:05:38.376889
2081	53	Cattle	s3://bucket/img.jpg	{56,58,59}	19.037094	72.994574	2026-09-03 00:05:38.376889
2082	130	Buffalo	s3://bucket/img.jpg	{64,66,67,35,68,36,62}	30.994716	75.011435	2026-09-03 00:05:38.376889
2083	462	Pig	s3://bucket/img.jpg	{9,3,6,7}	25.984889	92.046633	2026-09-03 00:05:38.376889
2084	127	Sheep	s3://bucket/img.jpg	{12,13,14}	30.980681	74.992781	2026-09-03 00:05:38.376889
2085	52	Poultry	s3://bucket/img.jpg	{6,12,16,17,19,22}	18.992967	72.999984	2026-09-03 00:05:38.376889
2086	208	Cattle	s3://bucket/img.jpg	{65,35,62,63}	30.968698	74.950211	2026-09-03 00:05:38.376889
2087	456	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.013493	73.043861	2026-09-03 00:05:38.376889
2088	231	Pig	s3://bucket/img.jpg	{35,53,54,55}	8.760711	76.315879	2026-09-03 00:05:38.376889
2089	183	Sheep	s3://bucket/img.jpg	{32,27,30}	26.044974	91.990251	2026-09-03 00:05:38.376889
2090	376	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.004373	75.008659	2026-09-03 00:05:38.376889
2091	346	Poultry	s3://bucket/img.jpg	{6,12,17,18,19,22}	32.711101	87.766055	2026-09-03 00:05:38.376889
2092	150	Goat	s3://bucket/img.jpg	{4,37,36,39,40,41}	31.016192	74.973223	2026-09-03 00:05:38.376889
2093	136	Pig	s3://bucket/img.jpg	{3,5,6,8,9,10}	26.019946	91.980126	2026-09-03 00:05:38.376889
2094	118	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.043616	73.042981	2026-09-03 00:05:38.376889
2095	136	Sheep	s3://bucket/img.jpg	{50,27,30}	25.977705	91.966552	2026-09-03 00:05:38.376889
2096	340	Buffalo	s3://bucket/img.jpg	{64,66,67,68,55}	19.015123	73.021683	2026-09-03 00:05:38.376889
2097	120	Buffalo	s3://bucket/img.jpg	{66,67,68,62,63}	31.313312	93.356366	2026-09-03 00:05:38.376889
2098	340	Cattle	s3://bucket/img.jpg	{64,65,67,35,62}	19.019382	72.973240	2026-09-03 00:05:38.376889
2099	299	Buffalo	s3://bucket/img.jpg	{2,56,58,59,61}	19.030879	72.974729	2026-09-03 00:05:38.376889
2100	113	Cattle	s3://bucket/img.jpg	{1,12,14}	30.997826	75.026991	2026-09-03 00:05:38.376889
2101	304	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	31.002593	74.956263	2026-09-03 00:05:38.376889
2102	177	Cattle	s3://bucket/img.jpg	{1,12,13,14}	31.042427	74.999947	2026-09-03 00:05:38.376889
2103	302	Goat	s3://bucket/img.jpg	{41,35,38,14}	31.012315	74.983777	2026-09-03 00:05:38.376889
2104	369	Pig	s3://bucket/img.jpg	{3,1,11}	18.969737	72.964640	2026-09-03 00:05:38.376889
2105	238	Buffalo	s3://bucket/img.jpg	{64,65,35,67,47,63}	30.963921	75.044364	2026-09-03 00:05:38.376889
2106	225	Cattle	s3://bucket/img.jpg	{64,62,63}	31.028399	75.026419	2026-09-03 00:05:38.376889
2107	220	Pig	s3://bucket/img.jpg	{35,54,55}	19.022915	73.007881	2026-09-03 00:05:38.376889
2108	177	Poultry	s3://bucket/img.jpg	{17,18,21,6}	31.017120	74.962374	2026-09-03 00:05:38.376889
2109	148	Cattle	s3://bucket/img.jpg	{2,59,58}	26.027856	91.963915	2026-09-03 00:05:38.376889
2110	253	Sheep	s3://bucket/img.jpg	{32,1,34,29,30,31}	26.086036	93.649355	2026-09-03 00:05:38.376889
2111	292	Sheep	s3://bucket/img.jpg	{4,69}	22.738773	86.675945	2026-09-03 00:05:38.376889
2112	485	Sheep	s3://bucket/img.jpg	{48,4,69}	24.277242	68.562112	2026-09-03 00:05:38.376889
2113	207	Sheep	s3://bucket/img.jpg	{35,47,49,52,21,27,30}	30.976435	74.983941	2026-09-03 00:05:38.376889
2114	144	Goat	s3://bucket/img.jpg	{35,47,48,52,27}	18.973862	72.996802	2026-09-03 00:05:38.376889
2115	8	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.973251	92.031041	2026-09-03 00:05:38.376889
2116	248	Sheep	s3://bucket/img.jpg	{4,69}	26.034185	92.001497	2026-09-03 00:05:38.376889
2117	104	Poultry	s3://bucket/img.jpg	{17,18,12,6}	31.041513	74.984441	2026-09-03 00:05:38.376889
2118	8	Cattle	s3://bucket/img.jpg	{2,56,58,60,61}	25.999304	91.983068	2026-09-03 00:05:38.376889
2119	491	Poultry	s3://bucket/img.jpg	{16,19,6}	27.590467	80.170779	2026-09-03 00:05:38.376889
2120	76	Cattle	s3://bucket/img.jpg	{1,12,13,14}	25.988277	92.039941	2026-09-03 00:05:38.376889
2121	310	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	26.019366	92.022433	2026-09-03 00:05:38.376889
2122	51	Goat	s3://bucket/img.jpg	{1,12,13,14}	26.033539	91.964831	2026-09-03 00:05:38.376889
2123	182	Cattle	s3://bucket/img.jpg	{1,12,13,14}	25.981414	92.025750	2026-09-03 00:05:38.376889
2124	306	Buffalo	s3://bucket/img.jpg	{2,43,45}	25.981982	92.027593	2026-09-03 00:05:38.376889
2125	15	Poultry	s3://bucket/img.jpg	{19,12,21,15}	19.027295	72.974031	2026-09-03 00:05:38.376889
2126	37	Pig	s3://bucket/img.jpg	{9,11,5}	19.021909	73.030059	2026-09-03 00:05:38.376889
2127	101	Cattle	s3://bucket/img.jpg	{49,27,47}	25.988289	91.993898	2026-09-03 00:05:38.376889
2128	110	Sheep	s3://bucket/img.jpg	{49,51,52,27,30}	31.048320	75.015652	2026-09-03 00:05:38.376889
2129	319	Cattle	s3://bucket/img.jpg	{24,25,26,23}	11.196506	85.981185	2026-09-03 00:05:38.376889
2130	175	Buffalo	s3://bucket/img.jpg	{43,44,45,46}	19.040507	73.009499	2026-09-03 00:05:38.376889
2131	12	Goat	s3://bucket/img.jpg	{40,36,39}	19.016350	72.971623	2026-09-03 00:05:38.376889
2132	441	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.959413	92.023744	2026-09-03 00:05:38.376889
2133	437	Sheep	s3://bucket/img.jpg	{4,69}	18.964249	72.970552	2026-09-03 00:05:38.376889
2134	488	Pig	s3://bucket/img.jpg	{2,3,5,9,10,11}	19.045500	72.964688	2026-09-03 00:05:38.376889
2135	365	Goat	s3://bucket/img.jpg	{4,69}	18.964066	72.995900	2026-09-03 00:05:38.376889
2136	477	Cattle	s3://bucket/img.jpg	{2,45,46}	31.006206	75.032067	2026-09-03 00:05:38.376889
2137	254	Cattle	s3://bucket/img.jpg	{59,60,61}	30.959570	75.011120	2026-09-03 00:05:38.376889
2138	396	Pig	s3://bucket/img.jpg	{1,2,3,6,7,8}	30.963068	74.962611	2026-09-03 00:05:38.376889
2139	35	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.047786	72.986982	2026-09-03 00:05:38.376889
2140	331	Goat	s3://bucket/img.jpg	{4,69}	12.895748	86.044963	2026-09-03 00:05:38.376889
2141	354	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.020632	92.013597	2026-09-03 00:05:38.376889
2142	406	Buffalo	s3://bucket/img.jpg	{64,65,66,67,35,62}	31.830613	91.009606	2026-09-03 00:05:38.376889
2143	107	Sheep	s3://bucket/img.jpg	{35,4,37,36,39}	8.455160	86.792027	2026-09-03 00:05:38.376889
2144	167	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	18.962118	72.965845	2026-09-03 00:05:38.376889
2145	86	Pig	s3://bucket/img.jpg	{1,3,5,7,28}	25.978941	92.045889	2026-09-03 00:05:38.376889
2146	481	Sheep	s3://bucket/img.jpg	{12,13,14}	31.044446	75.041559	2026-09-03 00:05:38.376889
2147	166	Cattle	s3://bucket/img.jpg	{32,1,11,28,29,30,31}	19.022830	72.967245	2026-09-03 00:05:38.376889
2148	137	Pig	s3://bucket/img.jpg	{10,2,4}	26.031456	91.952806	2026-09-03 00:05:38.376889
2149	162	Sheep	s3://bucket/img.jpg	{27,35,30}	25.966889	91.955030	2026-09-03 00:05:38.376889
2150	215	Poultry	s3://bucket/img.jpg	{18,12,6,22}	25.965131	91.990053	2026-09-03 00:05:38.376889
2151	87	Sheep	s3://bucket/img.jpg	{32,1,33,27,30,31}	24.913690	93.773572	2026-09-03 00:05:38.376889
2152	333	Goat	s3://bucket/img.jpg	{4,69}	26.019867	91.959359	2026-09-03 00:05:38.376889
2153	429	Pig	s3://bucket/img.jpg	{35,54,55}	19.186182	91.288372	2026-09-03 00:05:38.376889
2154	192	Sheep	s3://bucket/img.jpg	{4,69}	18.963859	73.012454	2026-09-03 00:05:38.376889
2155	152	Sheep	s3://bucket/img.jpg	{32,11,27,30}	25.963045	92.007529	2026-09-03 00:05:38.376889
2156	399	Cattle	s3://bucket/img.jpg	{12,14}	22.323244	94.808950	2026-09-03 00:05:38.376889
2157	99	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.047011	72.982365	2026-09-03 00:05:38.376889
2158	485	Cattle	s3://bucket/img.jpg	{25,26,23}	19.014927	72.962294	2026-09-03 00:05:38.376889
2159	232	Sheep	s3://bucket/img.jpg	{4,69}	26.008464	81.034748	2026-09-03 00:05:38.376889
2160	360	Poultry	s3://bucket/img.jpg	{17,18,19,20}	31.026414	75.027277	2026-09-03 00:05:38.376889
2161	210	Cattle	s3://bucket/img.jpg	{24,25,26,23}	22.090297	82.793108	2026-09-03 00:05:38.376889
2162	86	Cattle	s3://bucket/img.jpg	{33,27,30,31}	25.980198	91.953923	2026-09-03 00:05:38.376889
2163	445	Poultry	s3://bucket/img.jpg	{19,12,22,6}	26.009029	91.995926	2026-09-03 00:05:38.376889
2164	62	Cattle	s3://bucket/img.jpg	{43,44,46}	26.009565	91.973847	2026-09-03 00:05:38.376889
2165	79	Sheep	s3://bucket/img.jpg	{32,33,34,29,30}	18.963278	72.980005	2026-09-03 00:05:38.376889
2166	67	Sheep	s3://bucket/img.jpg	{32,34,27,28,29,31}	18.952371	72.952831	2026-09-03 00:05:38.376889
2167	2	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.049250	92.014320	2026-09-03 00:05:38.376889
2168	153	Pig	s3://bucket/img.jpg	{1,2,3,10,11}	31.028730	74.993507	2026-09-03 00:05:38.376889
2169	498	Cattle	s3://bucket/img.jpg	{64,35,68,62,63}	30.985900	75.016364	2026-09-03 00:05:38.376889
2170	298	Cattle	s3://bucket/img.jpg	{1,28,29,30,31}	13.225074	89.952202	2026-09-03 00:05:38.376889
2171	285	Pig	s3://bucket/img.jpg	{35,53,54,55}	25.995425	92.031527	2026-09-03 00:05:38.376889
2172	464	Cattle	s3://bucket/img.jpg	{25,26,23}	24.251874	83.850680	2026-09-03 00:05:38.376889
2173	398	Sheep	s3://bucket/img.jpg	{50,27,52,30}	31.010926	75.014338	2026-09-03 00:05:38.376889
2174	251	Cattle	s3://bucket/img.jpg	{24,26,23}	26.009106	91.962357	2026-09-03 00:05:38.376889
2175	265	Pig	s3://bucket/img.jpg	{32,2,5,7,10,11}	19.017321	73.020272	2026-09-03 00:05:38.376889
2176	145	Pig	s3://bucket/img.jpg	{1,2,4,6,9,10}	18.958984	73.007151	2026-09-03 00:05:38.376889
2177	491	Sheep	s3://bucket/img.jpg	{4,69,52}	26.016411	92.022161	2026-09-03 00:05:38.376889
2178	262	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.188334	87.369420	2026-09-03 00:05:38.376889
2179	212	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46,27}	19.013944	73.048240	2026-09-03 00:05:38.376889
2180	170	Sheep	s3://bucket/img.jpg	{35,4,37,36,42}	9.503893	70.631945	2026-09-03 00:05:38.376889
2181	12	Pig	s3://bucket/img.jpg	{3,2,11,7}	31.024623	75.027101	2026-09-03 00:05:38.376889
2182	182	Goat	s3://bucket/img.jpg	{41,35,4,39}	27.571409	83.154488	2026-09-03 00:05:38.376889
2183	402	Sheep	s3://bucket/img.jpg	{32,1,33,34,27,31}	12.032884	76.818305	2026-09-03 00:05:38.376889
2184	388	Goat	s3://bucket/img.jpg	{4,69}	25.964842	91.957196	2026-09-03 00:05:38.376889
2185	130	Pig	s3://bucket/img.jpg	{5,7,8,10,11}	25.997580	92.009343	2026-09-03 00:05:38.376889
2186	76	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.014427	91.990848	2026-09-03 00:05:38.376889
2187	81	Poultry	s3://bucket/img.jpg	{6,12,16,20,22}	10.709338	76.255434	2026-09-03 00:05:38.376889
2188	334	Sheep	s3://bucket/img.jpg	{57,59,60,61}	14.897639	87.426106	2026-09-03 00:05:38.376889
2189	73	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.020163	74.999077	2026-09-03 00:05:38.376889
2190	349	Cattle	s3://bucket/img.jpg	{25,26,23}	26.049210	91.996685	2026-09-03 00:05:38.376889
2191	160	Cattle	s3://bucket/img.jpg	{24,26,23}	32.402633	70.133221	2026-09-03 00:05:38.376889
2192	139	Sheep	s3://bucket/img.jpg	{4,69}	25.983220	92.007358	2026-09-03 00:05:38.376889
2193	1	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.968209	92.030582	2026-09-03 00:05:38.376889
2194	392	Pig	s3://bucket/img.jpg	{35,53,54,55}	10.654235	75.140252	2026-09-03 00:05:38.376889
2195	162	Pig	s3://bucket/img.jpg	{48,49,51,52,27,30}	19.043782	72.979357	2026-09-03 00:05:38.376889
2196	344	Goat	s3://bucket/img.jpg	{4,69,63}	31.034741	75.009799	2026-09-03 00:05:38.376889
2197	428	Cattle	s3://bucket/img.jpg	{24,26,23}	30.956555	75.036974	2026-09-03 00:05:38.376889
2198	282	Sheep	s3://bucket/img.jpg	{35,36,39,40,41,42}	27.049402	77.718760	2026-09-03 00:05:38.376889
2199	187	Goat	s3://bucket/img.jpg	{35,4,36,37,39}	18.951773	73.044967	2026-09-03 00:05:38.376889
2200	48	Cattle	s3://bucket/img.jpg	{57,59,60,61}	33.763190	74.182780	2026-09-03 00:05:38.376889
2201	122	Sheep	s3://bucket/img.jpg	{1,12,13,14}	30.964503	75.000848	2026-09-03 00:05:38.376889
2202	225	Pig	s3://bucket/img.jpg	{49,27,52}	21.831326	71.484701	2026-09-03 00:05:38.376889
2203	441	Pig	s3://bucket/img.jpg	{2,3,7,8,11}	18.968409	73.025762	2026-09-03 00:05:38.376889
2204	216	Cattle	s3://bucket/img.jpg	{1,27,28,33}	31.008492	74.960907	2026-09-03 00:05:38.376889
2205	348	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.979225	73.010008	2026-09-03 00:05:38.376889
2206	66	Sheep	s3://bucket/img.jpg	{4,69}	26.030207	91.981656	2026-09-03 00:05:38.376889
2207	206	Cattle	s3://bucket/img.jpg	{34,30,31}	30.965509	75.015776	2026-09-03 00:05:38.376889
2208	212	Pig	s3://bucket/img.jpg	{1,5,6,8,10,11}	11.517933	94.434004	2026-09-03 00:05:38.376889
2209	110	Sheep	s3://bucket/img.jpg	{4,36,37,39,40,42}	19.008935	73.040993	2026-09-03 00:05:38.376889
2210	137	Cattle	s3://bucket/img.jpg	{56,59,60}	26.046609	92.048546	2026-09-03 00:05:38.376889
2211	35	Sheep	s3://bucket/img.jpg	{27,29,30,31}	25.954140	92.038334	2026-09-03 00:05:38.376889
2212	420	Goat	s3://bucket/img.jpg	{1,12,13,14}	26.347597	79.693456	2026-09-03 00:05:38.376889
2213	190	Goat	s3://bucket/img.jpg	{36,4,38}	18.994951	73.004073	2026-09-03 00:05:38.376889
2214	320	Goat	s3://bucket/img.jpg	{1,12,13,14}	25.951011	91.985468	2026-09-03 00:05:38.376889
2215	483	Buffalo	s3://bucket/img.jpg	{2,34,57,58,59,60,61}	30.993584	75.016298	2026-09-03 00:05:38.376889
2216	289	Poultry	s3://bucket/img.jpg	{19,12,21}	31.036219	75.038680	2026-09-03 00:05:38.376889
2217	487	Goat	s3://bucket/img.jpg	{36,4,38,39,37,41,25}	25.981582	92.045952	2026-09-03 00:05:38.376889
2218	343	Goat	s3://bucket/img.jpg	{4,69}	31.004956	74.962000	2026-09-03 00:05:38.376889
2219	425	Cattle	s3://bucket/img.jpg	{1,12,13,14}	9.663250	82.021222	2026-09-03 00:05:38.376889
2220	152	Cattle	s3://bucket/img.jpg	{2,43,46}	26.012148	92.007380	2026-09-03 00:05:38.376889
2221	443	Cattle	s3://bucket/img.jpg	{2,56,57,59,60,61}	25.974213	92.007787	2026-09-03 00:05:38.376889
2222	324	Poultry	s3://bucket/img.jpg	{16,19,12,22}	19.029372	72.952835	2026-09-03 00:05:38.376889
2223	73	Buffalo	s3://bucket/img.jpg	{65,66,35,47,62,63}	26.641970	81.170013	2026-09-03 00:05:38.376889
2224	210	Buffalo	s3://bucket/img.jpg	{64,65,66,63}	30.969411	75.045569	2026-09-03 00:05:38.376889
2225	377	Buffalo	s3://bucket/img.jpg	{64,66,35,47,63}	26.006862	91.968899	2026-09-03 00:05:38.376889
2226	495	Cattle	s3://bucket/img.jpg	{65,66,63}	31.006471	75.017976	2026-09-03 00:05:38.376889
2227	127	Buffalo	s3://bucket/img.jpg	{64,65,66,62}	25.990510	91.978801	2026-09-03 00:05:38.376889
2228	168	Poultry	s3://bucket/img.jpg	{12,15,16,18,19,20}	25.981252	91.967919	2026-09-03 00:05:38.376889
2229	5	Buffalo	s3://bucket/img.jpg	{65,35,68,52,63}	18.987284	72.959732	2026-09-03 00:05:38.376889
2230	211	Goat	s3://bucket/img.jpg	{35,36,37,40,41,42}	26.024973	91.987396	2026-09-03 00:05:38.376889
2231	481	Cattle	s3://bucket/img.jpg	{64,65,35}	30.970230	74.950898	2026-09-03 00:05:38.376889
2232	55	Pig	s3://bucket/img.jpg	{1,3,4,6,8,9}	18.973307	73.042188	2026-09-03 00:05:38.376889
2233	312	Cattle	s3://bucket/img.jpg	{64,67,35,47,62,63}	25.974426	91.950991	2026-09-03 00:05:38.376889
2234	272	Poultry	s3://bucket/img.jpg	{15,16,17,18,19}	25.963417	92.018748	2026-09-03 00:05:38.376889
2235	16	Cattle	s3://bucket/img.jpg	{64,65,47}	19.040358	72.972513	2026-09-03 00:05:38.376889
2236	1	Cattle	s3://bucket/img.jpg	{47,23,24,25,26}	20.161953	74.138707	2026-09-03 00:05:38.376889
2237	443	Pig	s3://bucket/img.jpg	{9,2,4,5}	10.634509	88.969576	2026-09-03 00:05:38.376889
2238	301	Cattle	s3://bucket/img.jpg	{43,23,24,25,26}	18.968189	72.965595	2026-09-03 00:05:38.376889
2239	119	Cattle	s3://bucket/img.jpg	{32,33,1,27,29,30}	25.985686	92.042736	2026-09-03 00:05:38.376889
2240	45	Cattle	s3://bucket/img.jpg	{12,13,14}	30.968312	75.009527	2026-09-03 00:05:38.376889
2241	158	Sheep	s3://bucket/img.jpg	{42,38,39}	26.043776	92.011778	2026-09-03 00:05:38.376889
2242	182	Sheep	s3://bucket/img.jpg	{1,12,13,14}	18.987164	73.041556	2026-09-03 00:05:38.376889
2243	474	Pig	s3://bucket/img.jpg	{2,3,5,7,11}	18.987807	73.023780	2026-09-03 00:05:38.376889
2244	251	Poultry	s3://bucket/img.jpg	{12,15,17,18,21,22}	18.980634	72.952532	2026-09-03 00:05:38.376889
2245	400	Poultry	s3://bucket/img.jpg	{18,12,15}	31.049850	74.969178	2026-09-03 00:05:38.376889
2246	212	Buffalo	s3://bucket/img.jpg	{2,43,44,45}	18.984746	72.976116	2026-09-03 00:05:38.376889
2247	161	Sheep	s3://bucket/img.jpg	{1,27,31,33}	25.987190	92.009558	2026-09-03 00:05:38.376889
2248	190	Goat	s3://bucket/img.jpg	{48,50,47}	31.690552	84.857213	2026-09-03 00:05:38.376889
2249	132	Sheep	s3://bucket/img.jpg	{32,1,34,33,27,28,62}	25.992475	92.043283	2026-09-03 00:05:38.376889
2250	242	Cattle	s3://bucket/img.jpg	{24,25,26,23}	16.956398	73.168316	2026-09-03 00:05:38.376889
2251	426	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.962147	91.985394	2026-09-03 00:05:38.376889
2252	208	Pig	s3://bucket/img.jpg	{35,53,54,55}	17.462411	82.679340	2026-09-03 00:05:38.376889
2253	461	Goat	s3://bucket/img.jpg	{47,51,52,27,30}	18.998725	72.950635	2026-09-03 00:05:38.376889
2254	324	Cattle	s3://bucket/img.jpg	{48,30,47}	25.956300	92.018509	2026-09-03 00:05:38.376889
2255	126	Goat	s3://bucket/img.jpg	{4,69}	19.048612	73.049330	2026-09-03 00:05:38.376889
2256	27	Cattle	s3://bucket/img.jpg	{1,66,30,33}	31.026331	74.989450	2026-09-03 00:05:38.376889
2257	374	Cattle	s3://bucket/img.jpg	{35,38,48,49,52,27}	30.970597	75.046291	2026-09-03 00:05:38.376889
2258	113	Goat	s3://bucket/img.jpg	{35,4,37,39,40,42}	18.963149	73.011066	2026-09-03 00:05:38.376889
2259	335	Goat	s3://bucket/img.jpg	{35,48,49,50,51,27}	25.961257	91.950889	2026-09-03 00:05:38.376889
2260	272	Goat	s3://bucket/img.jpg	{37,38,39,40,42}	26.021869	91.968591	2026-09-03 00:05:38.376889
2261	95	Pig	s3://bucket/img.jpg	{35,53,54,55}	17.568196	74.386689	2026-09-03 00:05:38.376889
2262	18	Sheep	s3://bucket/img.jpg	{50,27,52}	30.303203	74.363688	2026-09-03 00:05:38.376889
2263	266	Sheep	s3://bucket/img.jpg	{41,35,4,36}	25.950530	92.023330	2026-09-03 00:05:38.376889
2264	312	Goat	s3://bucket/img.jpg	{40,42,35,37}	21.582718	88.478023	2026-09-03 00:05:38.376889
2265	182	Sheep	s3://bucket/img.jpg	{48,27,35,30}	25.950411	92.017060	2026-09-03 00:05:38.376889
2266	493	Sheep	s3://bucket/img.jpg	{2,56,57,58,59,61}	18.971706	72.965712	2026-09-03 00:05:38.376889
2267	489	Goat	s3://bucket/img.jpg	{4,69}	20.913014	77.471692	2026-09-03 00:05:38.376889
2268	74	Cattle	s3://bucket/img.jpg	{2,57,58,60,61}	21.017603	70.515593	2026-09-03 00:05:38.376889
2269	342	Goat	s3://bucket/img.jpg	{48,51,27,47}	26.009229	92.042292	2026-09-03 00:05:38.376889
2270	104	Sheep	s3://bucket/img.jpg	{48,27,52,68}	34.494187	93.725663	2026-09-03 00:05:38.376889
2271	201	Poultry	s3://bucket/img.jpg	{16,18,15}	25.297445	82.499057	2026-09-03 00:05:38.376889
2272	437	Cattle	s3://bucket/img.jpg	{1,7,12,13,14}	26.240724	86.718190	2026-09-03 00:05:38.376889
2273	438	Goat	s3://bucket/img.jpg	{4,69}	30.970992	74.967907	2026-09-03 00:05:38.376889
2274	288	Pig	s3://bucket/img.jpg	{2,3,6,7,9,10}	30.985086	74.967739	2026-09-03 00:05:38.376889
2275	289	Buffalo	s3://bucket/img.jpg	{2,45,46}	30.976230	75.003614	2026-09-03 00:05:38.376889
2276	177	Cattle	s3://bucket/img.jpg	{64,35,62}	19.030258	73.016820	2026-09-03 00:05:38.376889
2277	195	Cattle	s3://bucket/img.jpg	{24,25,26,23}	27.125668	88.760677	2026-09-03 00:05:38.376889
2278	163	Goat	s3://bucket/img.jpg	{4,69}	30.978261	74.980101	2026-09-03 00:05:38.376889
2279	231	Buffalo	s3://bucket/img.jpg	{57,58,2}	18.995565	73.014073	2026-09-03 00:05:38.376889
2280	52	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.006385	72.996125	2026-09-03 00:05:38.376889
2281	455	Cattle	s3://bucket/img.jpg	{64,66,67}	26.034374	92.035460	2026-09-03 00:05:38.376889
2282	419	Sheep	s3://bucket/img.jpg	{1,12,13}	32.553469	92.894113	2026-09-03 00:05:38.376889
2283	404	Sheep	s3://bucket/img.jpg	{11,4,69}	31.009887	75.033497	2026-09-03 00:05:38.376889
2284	75	Poultry	s3://bucket/img.jpg	{6,15,17,18,21,22}	11.199123	76.071259	2026-09-03 00:05:38.376889
2285	353	Pig	s3://bucket/img.jpg	{1,4,6,8,10,11}	21.236049	82.649628	2026-09-03 00:05:38.376889
2286	5	Goat	s3://bucket/img.jpg	{1,12,13,14}	28.259841	82.301110	2026-09-03 00:05:38.376889
2287	498	Buffalo	s3://bucket/img.jpg	{64,66,35,47,63}	25.964737	91.999817	2026-09-03 00:05:38.376889
2288	139	Cattle	s3://bucket/img.jpg	{35,49,51,52,27,30}	31.042796	74.957819	2026-09-03 00:05:38.376889
2289	396	Poultry	s3://bucket/img.jpg	{12,15,16,17,19,22}	19.012988	73.006152	2026-09-03 00:05:38.376889
2290	492	Poultry	s3://bucket/img.jpg	{6,16,17,18,19,21}	25.950483	92.036197	2026-09-03 00:05:38.376889
2291	48	Cattle	s3://bucket/img.jpg	{32,1,33,27,28,29}	18.992553	72.991982	2026-09-03 00:05:38.376889
2292	234	Sheep	s3://bucket/img.jpg	{4,69}	25.998679	92.035893	2026-09-03 00:05:38.376889
2293	31	Cattle	s3://bucket/img.jpg	{43,44,45,46}	22.574313	79.896778	2026-09-03 00:05:38.376889
2294	56	Goat	s3://bucket/img.jpg	{47,48,49,50,51,30}	30.989038	74.979923	2026-09-03 00:05:38.376889
2295	217	Poultry	s3://bucket/img.jpg	{18,21,22,15}	22.906492	91.111266	2026-09-03 00:05:38.376889
2296	331	Cattle	s3://bucket/img.jpg	{49,52,30}	30.977952	75.039063	2026-09-03 00:05:38.376889
2297	462	Buffalo	s3://bucket/img.jpg	{2,57,58,59,60,61}	30.513634	91.611677	2026-09-03 00:05:38.376889
2298	208	Goat	s3://bucket/img.jpg	{4,69}	18.981456	73.024119	2026-09-03 00:05:38.376889
2299	494	Buffalo	s3://bucket/img.jpg	{64,66,35,67,68}	30.973280	75.005318	2026-09-03 00:05:38.376889
2300	389	Sheep	s3://bucket/img.jpg	{1,12,13,14}	25.969949	91.993129	2026-09-03 00:05:38.376889
2301	67	Goat	s3://bucket/img.jpg	{35,4,38,40,41,42}	25.974437	91.953793	2026-09-03 00:05:38.376889
2302	177	Poultry	s3://bucket/img.jpg	{16,18,15}	31.046494	74.969060	2026-09-03 00:05:38.376889
2303	19	Cattle	s3://bucket/img.jpg	{32,1,34,28}	10.167305	86.614220	2026-09-03 00:05:38.376889
2304	39	Sheep	s3://bucket/img.jpg	{4,69}	28.078290	94.225467	2026-09-03 00:05:38.376889
2305	10	Sheep	s3://bucket/img.jpg	{32,33,28,31}	25.965875	92.014449	2026-09-03 00:05:38.376889
2306	270	Sheep	s3://bucket/img.jpg	{1,13,14}	9.796119	82.771185	2026-09-03 00:05:38.376889
2307	234	Sheep	s3://bucket/img.jpg	{34,28,31}	29.886034	82.303441	2026-09-03 00:05:38.376889
2308	464	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.979892	73.008443	2026-09-03 00:05:38.376889
2309	347	Pig	s3://bucket/img.jpg	{49,50,51,27,30}	18.994838	72.971254	2026-09-03 00:05:38.376889
2310	190	Sheep	s3://bucket/img.jpg	{48,49,27}	19.014877	73.026500	2026-09-03 00:05:38.376889
2311	318	Cattle	s3://bucket/img.jpg	{1,12,13,14}	18.434210	83.607296	2026-09-03 00:05:38.376889
2312	64	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	30.979555	75.049215	2026-09-03 00:05:38.376889
2313	454	Poultry	s3://bucket/img.jpg	{16,17,19,12}	19.020365	73.007122	2026-09-03 00:05:38.376889
2314	373	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.954844	73.047398	2026-09-03 00:05:38.376889
2315	448	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.811460	71.724259	2026-09-03 00:05:38.376889
2316	130	Sheep	s3://bucket/img.jpg	{4,69}	31.021584	75.034665	2026-09-03 00:05:38.376889
2317	360	Cattle	s3://bucket/img.jpg	{1,12,13,14}	8.904731	72.682321	2026-09-03 00:05:38.376889
2318	304	Cattle	s3://bucket/img.jpg	{25,26,23}	25.995267	91.958380	2026-09-03 00:05:38.376889
2319	248	Pig	s3://bucket/img.jpg	{35,53,54,55}	25.549244	75.919051	2026-09-03 00:05:38.376889
2320	44	Goat	s3://bucket/img.jpg	{40,41,36,38}	23.313210	94.175595	2026-09-03 00:05:38.376889
2321	370	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	19.022854	72.979094	2026-09-03 00:05:38.376889
2322	443	Goat	s3://bucket/img.jpg	{40,42,35,39}	31.019141	75.008496	2026-09-03 00:05:38.376889
2323	421	Sheep	s3://bucket/img.jpg	{40,35,4,38}	19.008465	73.024031	2026-09-03 00:05:38.376889
2324	267	Cattle	s3://bucket/img.jpg	{24,26,15,23}	28.365009	82.305112	2026-09-03 00:05:38.376889
2325	486	Buffalo	s3://bucket/img.jpg	{64,35,68,47,62}	30.982984	74.974538	2026-09-03 00:05:38.376889
2326	98	Cattle	s3://bucket/img.jpg	{12,14}	25.966764	92.022536	2026-09-03 00:05:38.376889
2327	493	Sheep	s3://bucket/img.jpg	{1,34,33,27,28,29}	26.031140	92.049075	2026-09-03 00:05:38.376889
2328	296	Goat	s3://bucket/img.jpg	{35,4,37,38}	25.972943	92.027875	2026-09-03 00:05:38.376889
2329	23	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.041749	72.961929	2026-09-03 00:05:38.376889
2330	353	Goat	s3://bucket/img.jpg	{1,12,13,14}	25.962441	91.968510	2026-09-03 00:05:38.376889
2331	393	Cattle	s3://bucket/img.jpg	{1,28,33}	19.890989	71.307162	2026-09-03 00:05:38.376889
2332	423	Buffalo	s3://bucket/img.jpg	{64,35,67}	22.409979	70.466006	2026-09-03 00:05:38.376889
2333	24	Pig	s3://bucket/img.jpg	{1,2,5,7,10}	11.353078	69.042487	2026-09-03 00:05:38.376889
2334	178	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.028764	92.047715	2026-09-03 00:05:38.376889
2335	410	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.958247	75.038864	2026-09-03 00:05:38.376889
2336	40	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.989931	75.043522	2026-09-03 00:05:38.376889
2337	150	Poultry	s3://bucket/img.jpg	{16,18,19,6}	30.988659	74.997534	2026-09-03 00:05:38.376889
2338	44	Buffalo	s3://bucket/img.jpg	{2,56,58,60,61}	18.959562	73.046156	2026-09-03 00:05:38.376889
2339	287	Cattle	s3://bucket/img.jpg	{2,44,45}	19.001721	72.989977	2026-09-03 00:05:38.376889
2340	142	Sheep	s3://bucket/img.jpg	{33,29,31}	18.958102	73.036736	2026-09-03 00:05:38.376889
2341	75	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	31.042095	74.985697	2026-09-03 00:05:38.376889
2342	322	Goat	s3://bucket/img.jpg	{35,50,52,27,30}	19.348191	88.227298	2026-09-03 00:05:38.376889
2343	324	Pig	s3://bucket/img.jpg	{10,3,4}	26.047470	91.985973	2026-09-03 00:05:38.376889
2344	433	Sheep	s3://bucket/img.jpg	{32,1,34,30}	25.960186	92.019131	2026-09-03 00:05:38.376889
2345	425	Cattle	s3://bucket/img.jpg	{32,33,34,28,29,31}	18.985843	72.955361	2026-09-03 00:05:38.376889
2346	326	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.043245	91.994673	2026-09-03 00:05:38.376889
2347	128	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.690679	72.398022	2026-09-03 00:05:38.376889
2348	23	Goat	s3://bucket/img.jpg	{40,42,35}	13.319606	74.537577	2026-09-03 00:05:38.376889
2349	345	Cattle	s3://bucket/img.jpg	{25,26,23}	19.702410	84.117555	2026-09-03 00:05:38.376889
2350	430	Poultry	s3://bucket/img.jpg	{12,17,20,21,22}	31.030749	74.955467	2026-09-03 00:05:38.376889
2351	400	Cattle	s3://bucket/img.jpg	{32,33,27,30,31}	26.039268	92.048048	2026-09-03 00:05:38.376889
2352	436	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.010517	75.026233	2026-09-03 00:05:38.376889
2353	339	Goat	s3://bucket/img.jpg	{4,69}	19.010673	73.044020	2026-09-03 00:05:38.376889
2354	420	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.982209	74.979733	2026-09-03 00:05:38.376889
2355	148	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.979537	75.030948	2026-09-03 00:05:38.376889
2356	236	Goat	s3://bucket/img.jpg	{35,47,48,51,52}	18.953177	73.017605	2026-09-03 00:05:38.376889
2357	108	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.014225	73.049246	2026-09-03 00:05:38.376889
2358	189	Goat	s3://bucket/img.jpg	{4,69,7}	18.973660	72.979256	2026-09-03 00:05:38.376889
2359	234	Goat	s3://bucket/img.jpg	{25,4,69}	30.996343	74.972454	2026-09-03 00:05:38.376889
2360	417	Buffalo	s3://bucket/img.jpg	{2,59,58}	26.044851	92.017898	2026-09-03 00:05:38.376889
2361	441	Sheep	s3://bucket/img.jpg	{57,59,61}	31.013048	74.956577	2026-09-03 00:05:38.376889
2362	362	Buffalo	s3://bucket/img.jpg	{32,2,56,57,58}	34.068139	71.150453	2026-09-03 00:05:38.376889
2363	121	Sheep	s3://bucket/img.jpg	{56,57,58,60}	32.552836	68.041449	2026-09-03 00:05:38.376889
2364	268	Poultry	s3://bucket/img.jpg	{16,12,6,63}	27.387889	69.034437	2026-09-03 00:05:38.376889
2365	37	Pig	s3://bucket/img.jpg	{8,3,2,11}	24.755170	85.166666	2026-09-03 00:05:38.376889
2366	430	Goat	s3://bucket/img.jpg	{4,69}	26.398107	73.760093	2026-09-03 00:05:38.376889
2367	401	Goat	s3://bucket/img.jpg	{4,37,36,39,41,42}	22.561436	84.985604	2026-09-03 00:05:38.376889
2368	284	Pig	s3://bucket/img.jpg	{2,4,5,8,10,31}	30.986414	75.023252	2026-09-03 00:05:38.376889
2369	352	Sheep	s3://bucket/img.jpg	{56,57,59,60}	24.099804	80.571388	2026-09-03 00:05:38.376889
2370	151	Pig	s3://bucket/img.jpg	{35,54,55}	19.037177	73.011178	2026-09-03 00:05:38.376889
2371	136	Cattle	s3://bucket/img.jpg	{47,48,50,51,52,27}	26.024260	91.989981	2026-09-03 00:05:38.376889
2372	201	Goat	s3://bucket/img.jpg	{40,4,37,39}	31.032817	75.022294	2026-09-03 00:05:38.376889
2373	131	Cattle	s3://bucket/img.jpg	{65,66,62,63}	26.003277	92.032179	2026-09-03 00:05:38.376889
2374	324	Goat	s3://bucket/img.jpg	{36,4,39}	11.583433	75.317245	2026-09-03 00:05:38.376889
2375	189	Pig	s3://bucket/img.jpg	{35,53,54,55}	25.968204	91.958138	2026-09-03 00:05:38.376889
2376	322	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.954086	72.998180	2026-09-03 00:05:38.376889
2377	253	Goat	s3://bucket/img.jpg	{40,42,35,39}	25.981646	91.964757	2026-09-03 00:05:38.376889
2378	291	Cattle	s3://bucket/img.jpg	{2,45,46}	24.399342	72.945791	2026-09-03 00:05:38.376889
2379	463	Cattle	s3://bucket/img.jpg	{32,1,33,28,29}	31.022140	74.972169	2026-09-03 00:05:38.376889
2380	370	Poultry	s3://bucket/img.jpg	{16,17,20,21}	30.979535	75.011113	2026-09-03 00:05:38.376889
2381	311	Pig	s3://bucket/img.jpg	{35,54,55}	30.967520	74.981671	2026-09-03 00:05:38.376889
2382	29	Buffalo	s3://bucket/img.jpg	{2,45,46}	26.011348	91.960831	2026-09-03 00:05:38.376889
2383	223	Buffalo	s3://bucket/img.jpg	{43,45,46}	31.017776	74.964369	2026-09-03 00:05:38.376889
2384	268	Poultry	s3://bucket/img.jpg	{12,15,16,20,21}	16.727710	74.811159	2026-09-03 00:05:38.376889
2385	306	Cattle	s3://bucket/img.jpg	{65,68,62}	30.951113	75.036286	2026-09-03 00:05:38.376889
2386	68	Sheep	s3://bucket/img.jpg	{32,33,27,29,30,31}	33.527831	90.582429	2026-09-03 00:05:38.376889
2387	314	Goat	s3://bucket/img.jpg	{48,49,50,42}	26.038445	91.966932	2026-09-03 00:05:38.376889
2388	456	Sheep	s3://bucket/img.jpg	{1,12,13,14}	30.857211	69.826672	2026-09-03 00:05:38.376889
2389	91	Cattle	s3://bucket/img.jpg	{50,51,52,47}	31.015173	75.023790	2026-09-03 00:05:38.376889
2390	464	Poultry	s3://bucket/img.jpg	{9,21,12,20}	30.991560	74.979524	2026-09-03 00:05:38.376889
2391	245	Pig	s3://bucket/img.jpg	{6,7,8,9,10}	31.037266	75.033019	2026-09-03 00:05:38.376889
2392	60	Cattle	s3://bucket/img.jpg	{1,34,28,29,30}	30.955066	74.984266	2026-09-03 00:05:38.376889
2393	139	Pig	s3://bucket/img.jpg	{4,5,9,10,11}	25.981108	91.996096	2026-09-03 00:05:38.376889
2394	165	Cattle	s3://bucket/img.jpg	{65,66,68}	26.026209	91.978374	2026-09-03 00:05:38.376889
2395	272	Sheep	s3://bucket/img.jpg	{32,1,27,30,31}	26.000601	91.955728	2026-09-03 00:05:38.376889
2396	212	Sheep	s3://bucket/img.jpg	{4,69}	29.890637	75.530746	2026-09-03 00:05:38.376889
2397	342	Buffalo	s3://bucket/img.jpg	{64,66,67,68}	26.038715	91.957259	2026-09-03 00:05:38.376889
2398	281	Goat	s3://bucket/img.jpg	{35,37,38,41,42}	9.521106	81.294810	2026-09-03 00:05:38.376889
2399	101	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	25.952956	92.001519	2026-09-03 00:05:38.376889
2400	331	Cattle	s3://bucket/img.jpg	{1,12,13,14}	18.995902	72.989019	2026-09-03 00:05:38.376889
2401	110	Buffalo	s3://bucket/img.jpg	{43,44,45,46}	25.985707	92.032647	2026-09-03 00:05:38.376889
2402	402	Cattle	s3://bucket/img.jpg	{24,25,26}	19.034307	72.982152	2026-09-03 00:05:38.376889
2403	352	Cattle	s3://bucket/img.jpg	{33,30,1}	25.987254	91.959817	2026-09-03 00:05:38.376889
2404	459	Buffalo	s3://bucket/img.jpg	{66,67,47,62,63}	25.984052	92.031354	2026-09-03 00:05:38.376889
2405	15	Sheep	s3://bucket/img.jpg	{4,36,38,39,40}	31.048022	75.029099	2026-09-03 00:05:38.376889
2406	64	Cattle	s3://bucket/img.jpg	{12,13,14}	30.965609	74.982649	2026-09-03 00:05:38.376889
2407	149	Buffalo	s3://bucket/img.jpg	{64,67,35,47,62,63}	16.236708	91.401387	2026-09-03 00:05:38.376889
2408	201	Pig	s3://bucket/img.jpg	{11,6,7}	19.013455	72.975334	2026-09-03 00:05:38.376889
2409	358	Sheep	s3://bucket/img.jpg	{35,48,50,27,30}	18.989078	72.979108	2026-09-03 00:05:38.376889
2410	10	Poultry	s3://bucket/img.jpg	{12,15,16,19,21,22}	33.081652	84.300418	2026-09-03 00:05:38.376889
2411	285	Sheep	s3://bucket/img.jpg	{4,69}	25.980898	92.035072	2026-09-03 00:05:38.376889
2412	125	Buffalo	s3://bucket/img.jpg	{56,57,60,61}	30.961548	74.961531	2026-09-03 00:05:38.376889
2413	496	Sheep	s3://bucket/img.jpg	{1,12,13,14}	26.048438	92.046320	2026-09-03 00:05:38.376889
2414	317	Pig	s3://bucket/img.jpg	{35,53,54}	31.026681	75.041758	2026-09-03 00:05:38.376889
2415	383	Goat	s3://bucket/img.jpg	{1,12,13,14,47}	26.013405	91.977423	2026-09-03 00:05:38.376889
2416	244	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	18.996516	72.999292	2026-09-03 00:05:38.376889
2417	109	Cattle	s3://bucket/img.jpg	{32,1,34,28,29,30}	19.016658	73.003388	2026-09-03 00:05:38.376889
2418	228	Sheep	s3://bucket/img.jpg	{1,12,13,14}	19.036205	72.970379	2026-09-03 00:05:38.376889
2419	66	Buffalo	s3://bucket/img.jpg	{65,66,35,67,47,49,63}	25.980234	92.049094	2026-09-03 00:05:38.376889
2420	194	Sheep	s3://bucket/img.jpg	{35,36,37,38,40,42}	14.270627	78.862113	2026-09-03 00:05:38.376889
2421	247	Sheep	s3://bucket/img.jpg	{35,38,39,40,42}	19.018719	73.046730	2026-09-03 00:05:38.376889
2422	105	Pig	s3://bucket/img.jpg	{35,53,54,55}	34.648535	91.175885	2026-09-03 00:05:38.376889
2423	34	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.013790	75.011162	2026-09-03 00:05:38.376889
2424	326	Pig	s3://bucket/img.jpg	{3,10,2}	16.444721	71.825249	2026-09-03 00:05:38.376889
2425	371	Cattle	s3://bucket/img.jpg	{24,26,23}	26.016476	91.967548	2026-09-03 00:05:38.376889
2426	326	Sheep	s3://bucket/img.jpg	{32,34,28,30}	19.013459	72.969144	2026-09-03 00:05:38.376889
2427	415	Goat	s3://bucket/img.jpg	{48,27,52,30}	17.251578	94.231247	2026-09-03 00:05:38.376889
2428	495	Cattle	s3://bucket/img.jpg	{33,28,1}	25.954278	92.029235	2026-09-03 00:05:38.376889
2429	224	Sheep	s3://bucket/img.jpg	{35,4,37,38,40,41}	31.025678	74.996496	2026-09-03 00:05:38.376889
2430	107	Pig	s3://bucket/img.jpg	{8,1,4,6}	19.041571	73.034702	2026-09-03 00:05:38.376889
2431	251	Goat	s3://bucket/img.jpg	{4,69}	19.004221	72.975708	2026-09-03 00:05:38.376889
2432	325	Cattle	s3://bucket/img.jpg	{48,49,50,52,27,30}	31.409686	72.886311	2026-09-03 00:05:38.376889
2433	427	Pig	s3://bucket/img.jpg	{8,10,11,5}	25.998749	92.035380	2026-09-03 00:05:38.376889
2434	95	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.031278	72.997546	2026-09-03 00:05:38.376889
2435	205	Pig	s3://bucket/img.jpg	{1,3,4,5,9}	33.555438	75.778516	2026-09-03 00:05:38.376889
2436	253	Cattle	s3://bucket/img.jpg	{32,27,28,29}	18.988989	73.009037	2026-09-03 00:05:38.376889
2437	45	Goat	s3://bucket/img.jpg	{41,35,38}	32.493997	76.844989	2026-09-03 00:05:38.376889
2438	283	Sheep	s3://bucket/img.jpg	{35,4,38,39,41,42,57}	8.913414	92.353566	2026-09-03 00:05:38.376889
2439	377	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.042610	75.002090	2026-09-03 00:05:38.376889
2440	368	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	8.727430	74.805752	2026-09-03 00:05:38.376889
2441	90	Buffalo	s3://bucket/img.jpg	{64,65,66,67,63}	18.975934	73.014640	2026-09-03 00:05:38.376889
2442	99	Goat	s3://bucket/img.jpg	{4,69}	25.979903	92.005878	2026-09-03 00:05:38.376889
2443	51	Buffalo	s3://bucket/img.jpg	{65,35,63,47}	25.952075	91.996931	2026-09-03 00:05:38.376889
2444	31	Buffalo	s3://bucket/img.jpg	{63,62,47}	22.440901	79.963393	2026-09-03 00:05:38.376889
2445	175	Pig	s3://bucket/img.jpg	{35,54,55}	32.102270	93.634627	2026-09-03 00:05:38.376889
2446	26	Cattle	s3://bucket/img.jpg	{65,67,68,35,62}	19.046588	73.012939	2026-09-03 00:05:38.376889
2447	35	Poultry	s3://bucket/img.jpg	{12,22,6,15}	25.996161	91.986503	2026-09-03 00:05:38.376889
2448	296	Cattle	s3://bucket/img.jpg	{66,67,68,63}	19.040387	72.993999	2026-09-03 00:05:38.376889
2449	280	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.988983	72.952192	2026-09-03 00:05:38.376889
2450	104	Cattle	s3://bucket/img.jpg	{2,43,46}	15.658152	83.296246	2026-09-03 00:05:38.376889
2451	100	Sheep	s3://bucket/img.jpg	{4,69}	19.041878	73.029725	2026-09-03 00:05:38.376889
2452	126	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.045824	72.962746	2026-09-03 00:05:38.376889
2453	445	Cattle	s3://bucket/img.jpg	{65,66,35,63}	21.604931	70.167063	2026-09-03 00:05:38.376889
2454	99	Goat	s3://bucket/img.jpg	{4,69}	25.996114	92.043115	2026-09-03 00:05:38.376889
2455	243	Sheep	s3://bucket/img.jpg	{12,13,14}	21.762112	71.699523	2026-09-03 00:05:38.376889
2456	231	Cattle	s3://bucket/img.jpg	{24,25,26,23}	29.630937	68.074395	2026-09-03 00:05:38.376889
2457	393	Sheep	s3://bucket/img.jpg	{1,12,13,14}	26.041112	92.020270	2026-09-03 00:05:38.376889
2458	64	Pig	s3://bucket/img.jpg	{49,27,35}	18.976204	73.030166	2026-09-03 00:05:38.376889
2459	73	Sheep	s3://bucket/img.jpg	{48,27,38,47}	18.961164	73.029838	2026-09-03 00:05:38.376889
2460	385	Sheep	s3://bucket/img.jpg	{35,4,37,39,41}	19.021350	72.973946	2026-09-03 00:05:38.376889
2461	138	Buffalo	s3://bucket/img.jpg	{2,45,46,31}	34.213467	77.219050	2026-09-03 00:05:38.376889
2462	291	Pig	s3://bucket/img.jpg	{35,53,54}	26.487174	71.646173	2026-09-03 00:05:38.376889
2463	410	Cattle	s3://bucket/img.jpg	{2,56,58,59,60,61}	31.034341	75.047897	2026-09-03 00:05:38.376889
2464	102	Cattle	s3://bucket/img.jpg	{24,25,26,23}	29.124047	91.010984	2026-09-03 00:05:38.376889
2465	23	Cattle	s3://bucket/img.jpg	{48,49,35,47}	26.006010	91.964766	2026-09-03 00:05:38.376889
2466	219	Goat	s3://bucket/img.jpg	{36,37,38,39,40,41}	19.046020	73.004094	2026-09-03 00:05:38.376889
2467	167	Sheep	s3://bucket/img.jpg	{4,69}	25.985478	91.970448	2026-09-03 00:05:38.376889
2468	106	Cattle	s3://bucket/img.jpg	{64,66,67,2,62,63}	18.950392	73.041810	2026-09-03 00:05:38.376889
2469	210	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.044563	73.016856	2026-09-03 00:05:38.376889
2470	177	Pig	s3://bucket/img.jpg	{1,2,4,7,9,10}	18.315707	89.730983	2026-09-03 00:05:38.376889
2471	492	Cattle	s3://bucket/img.jpg	{24,26,23}	26.005260	92.042720	2026-09-03 00:05:38.376889
2472	39	Sheep	s3://bucket/img.jpg	{57,58,59,60}	31.007167	74.984488	2026-09-03 00:05:38.376889
2473	288	Buffalo	s3://bucket/img.jpg	{43,44,46}	13.610109	81.676652	2026-09-03 00:05:38.376889
2474	257	Sheep	s3://bucket/img.jpg	{56,58,59,60,61}	25.984917	92.046637	2026-09-03 00:05:38.376889
2475	26	Goat	s3://bucket/img.jpg	{4,69}	8.542886	73.036681	2026-09-03 00:05:38.376889
2476	269	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.034868	75.000543	2026-09-03 00:05:38.376889
2477	48	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	19.041575	73.009487	2026-09-03 00:05:38.376889
2478	212	Sheep	s3://bucket/img.jpg	{4,69}	15.308232	94.221017	2026-09-03 00:05:38.376889
2479	367	Pig	s3://bucket/img.jpg	{1,11,4,7}	30.982737	74.952462	2026-09-03 00:05:38.376889
2480	387	Sheep	s3://bucket/img.jpg	{42,35,36}	25.960809	92.019492	2026-09-03 00:05:38.376889
2481	454	Pig	s3://bucket/img.jpg	{35,53,54}	16.198324	86.728296	2026-09-03 00:05:38.376889
2482	438	Sheep	s3://bucket/img.jpg	{33,34,1,29,30,31}	26.042624	92.019028	2026-09-03 00:05:38.376889
2483	211	Pig	s3://bucket/img.jpg	{1,10,4,7}	19.001693	73.012808	2026-09-03 00:05:38.376889
2484	396	Pig	s3://bucket/img.jpg	{3,6,7,8,10}	19.011422	73.015800	2026-09-03 00:05:38.376889
2485	453	Buffalo	s3://bucket/img.jpg	{64,35,62}	30.959676	74.997955	2026-09-03 00:05:38.376889
2486	208	Cattle	s3://bucket/img.jpg	{32,27,29,31}	28.703175	89.902001	2026-09-03 00:05:38.376889
2487	357	Sheep	s3://bucket/img.jpg	{1,26,13,14}	18.991162	72.984863	2026-09-03 00:05:38.376889
2488	203	Sheep	s3://bucket/img.jpg	{40,41,42,39}	25.994105	92.009014	2026-09-03 00:05:38.376889
2489	152	Pig	s3://bucket/img.jpg	{8,2,11,5}	26.018044	91.950125	2026-09-03 00:05:38.376889
2490	146	Sheep	s3://bucket/img.jpg	{33,30,1}	25.973250	92.020099	2026-09-03 00:05:38.376889
2491	373	Pig	s3://bucket/img.jpg	{8,5,6,7}	15.676757	83.334136	2026-09-03 00:05:38.376889
2492	404	Buffalo	s3://bucket/img.jpg	{64,68,47}	31.014844	74.960644	2026-09-03 00:05:38.376889
2493	192	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.909588	75.364179	2026-09-03 00:05:38.376889
2494	396	Sheep	s3://bucket/img.jpg	{56,58,60}	31.033208	75.024646	2026-09-03 00:05:38.376889
2495	474	Buffalo	s3://bucket/img.jpg	{64,66,35,67,63}	25.992090	91.994725	2026-09-03 00:05:38.376889
2496	41	Cattle	s3://bucket/img.jpg	{24,25,26}	19.004028	73.026864	2026-09-03 00:05:38.376889
2497	89	Buffalo	s3://bucket/img.jpg	{2,44,45}	25.958990	91.982551	2026-09-03 00:05:38.376889
2498	15	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	19.009069	72.988730	2026-09-03 00:05:38.376889
2499	15	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.955918	73.018128	2026-09-03 00:05:38.376889
2500	263	Pig	s3://bucket/img.jpg	{35,53,54,55}	23.631564	69.694607	2026-09-03 00:05:38.376889
2501	160	Pig	s3://bucket/img.jpg	{1,2,5}	8.595357	91.976074	2026-09-03 00:05:38.376889
2502	309	Cattle	s3://bucket/img.jpg	{43,44,46}	25.961064	91.972446	2026-09-03 00:05:38.376889
2503	405	Cattle	s3://bucket/img.jpg	{2,44,46}	26.351551	89.932827	2026-09-03 00:05:38.376889
2504	72	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.959213	91.954221	2026-09-03 00:05:38.376889
2505	406	Goat	s3://bucket/img.jpg	{4,69}	31.040927	75.033836	2026-09-03 00:05:38.376889
2506	272	Sheep	s3://bucket/img.jpg	{1,12}	31.149724	70.588311	2026-09-03 00:05:38.376889
2507	334	Sheep	s3://bucket/img.jpg	{4,69}	19.026596	72.974038	2026-09-03 00:05:38.376889
2508	286	Poultry	s3://bucket/img.jpg	{18,19,12,22}	30.962143	74.981605	2026-09-03 00:05:38.376889
2509	10	Sheep	s3://bucket/img.jpg	{1,12,13}	18.981843	72.965287	2026-09-03 00:05:38.376889
2510	493	Cattle	s3://bucket/img.jpg	{64,66,35,68,47,62}	18.956902	73.033193	2026-09-03 00:05:38.376889
2511	158	Sheep	s3://bucket/img.jpg	{4,69}	25.965592	91.976522	2026-09-03 00:05:38.376889
2512	95	Sheep	s3://bucket/img.jpg	{1,12,13}	26.036103	91.984917	2026-09-03 00:05:38.376889
2513	86	Poultry	s3://bucket/img.jpg	{18,19,6}	30.965520	74.967105	2026-09-03 00:05:38.376889
2514	402	Buffalo	s3://bucket/img.jpg	{2,56,57,58,61}	26.923769	76.380128	2026-09-03 00:05:38.376889
2515	349	Goat	s3://bucket/img.jpg	{1,12,13,14}	30.227875	70.700044	2026-09-03 00:05:38.376889
2516	1	Sheep	s3://bucket/img.jpg	{35,4,36,37,38,39}	19.028650	72.954498	2026-09-03 00:05:38.376889
2517	362	Pig	s3://bucket/img.jpg	{35,53,54,55}	12.705192	72.184672	2026-09-03 00:05:38.376889
2518	165	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.040801	92.040079	2026-09-03 00:05:38.376889
2519	166	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	26.019422	92.023494	2026-09-03 00:05:38.376889
2520	31	Pig	s3://bucket/img.jpg	{35,53,54,55}	34.736881	69.466423	2026-09-03 00:05:38.376889
2521	418	Sheep	s3://bucket/img.jpg	{4,69}	19.028050	73.013991	2026-09-03 00:05:38.376889
2522	10	Buffalo	s3://bucket/img.jpg	{64,67,68,63}	19.005436	72.965856	2026-09-03 00:05:38.376889
2523	496	Poultry	s3://bucket/img.jpg	{17,18,19,21,22}	25.982415	91.977740	2026-09-03 00:05:38.376889
2524	398	Goat	s3://bucket/img.jpg	{4,69}	13.917602	76.707765	2026-09-03 00:05:38.376889
2525	92	Cattle	s3://bucket/img.jpg	{35,10,47,50,51,27}	25.951807	91.982761	2026-09-03 00:05:38.376889
2526	337	Pig	s3://bucket/img.jpg	{8,1,5}	31.019347	74.991550	2026-09-03 00:05:38.376889
2527	298	Cattle	s3://bucket/img.jpg	{67,35,63,47}	11.090584	69.086136	2026-09-03 00:05:38.376889
2528	94	Sheep	s3://bucket/img.jpg	{1,12,13,14}	18.987293	73.047823	2026-09-03 00:05:38.376889
2529	289	Cattle	s3://bucket/img.jpg	{64,35,63}	26.003095	91.976370	2026-09-03 00:05:38.376889
2530	406	Buffalo	s3://bucket/img.jpg	{2,44,45,46}	19.077444	93.544042	2026-09-03 00:05:38.376889
2531	384	Sheep	s3://bucket/img.jpg	{32,1,29,31}	26.036400	91.973702	2026-09-03 00:05:38.376889
2532	120	Sheep	s3://bucket/img.jpg	{4,69}	25.998843	92.022162	2026-09-03 00:05:38.376889
2533	422	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.033415	72.951626	2026-09-03 00:05:38.376889
2534	38	Cattle	s3://bucket/img.jpg	{34,27,29,30,31}	29.197286	74.416301	2026-09-03 00:05:38.376889
2535	62	Cattle	s3://bucket/img.jpg	{24,25,26,23}	11.397643	93.533201	2026-09-03 00:05:38.376889
2536	185	Sheep	s3://bucket/img.jpg	{57,2,59,69}	15.370409	68.637816	2026-09-03 00:05:38.376889
2537	20	Cattle	s3://bucket/img.jpg	{1,34,33,27,31}	19.016865	73.010301	2026-09-03 00:05:38.376889
2538	124	Sheep	s3://bucket/img.jpg	{4,69}	18.955201	73.017247	2026-09-03 00:05:38.376889
2539	416	Goat	s3://bucket/img.jpg	{40,36,38}	31.018564	75.025555	2026-09-03 00:05:38.376889
2540	308	Pig	s3://bucket/img.jpg	{35,53,54,55,27}	30.951095	75.045708	2026-09-03 00:05:38.376889
2541	469	Cattle	s3://bucket/img.jpg	{1,29,30,33}	27.038719	90.667239	2026-09-03 00:05:38.376889
2542	225	Pig	s3://bucket/img.jpg	{9,10,4,1}	18.968772	72.958767	2026-09-03 00:05:38.376889
2543	248	Sheep	s3://bucket/img.jpg	{33,34,1}	10.137990	80.969338	2026-09-03 00:05:38.376889
2544	8	Pig	s3://bucket/img.jpg	{2,4,5,6,9,10,59}	30.951213	74.971843	2026-09-03 00:05:38.376889
2545	204	Buffalo	s3://bucket/img.jpg	{66,68,63,47}	31.018169	75.022788	2026-09-03 00:05:38.376889
2546	368	Buffalo	s3://bucket/img.jpg	{64,65,67}	29.288788	81.335363	2026-09-03 00:05:38.376889
2547	271	Cattle	s3://bucket/img.jpg	{64,35,62}	31.020394	74.970303	2026-09-03 00:05:38.376889
2548	374	Poultry	s3://bucket/img.jpg	{12,15,19,20,22}	26.048879	91.999135	2026-09-03 00:05:38.376889
2549	301	Cattle	s3://bucket/img.jpg	{2,56,57,58,59,60}	31.028109	74.973639	2026-09-03 00:05:38.376889
2550	196	Cattle	s3://bucket/img.jpg	{48,50,27}	30.990986	74.995440	2026-09-03 00:05:38.376889
2551	384	Cattle	s3://bucket/img.jpg	{56,57,2}	25.963521	92.040605	2026-09-03 00:05:38.376889
2552	234	Pig	s3://bucket/img.jpg	{35,53,54,55}	9.176603	76.535587	2026-09-03 00:05:38.376889
2553	284	Sheep	s3://bucket/img.jpg	{32,33,1,28,29,30}	25.978305	91.950850	2026-09-03 00:05:38.376889
2554	382	Cattle	s3://bucket/img.jpg	{33,27,30,31}	30.959544	74.989567	2026-09-03 00:05:38.376889
2555	286	Buffalo	s3://bucket/img.jpg	{64,65,66,68,47,63}	19.019437	73.032717	2026-09-03 00:05:38.376889
2556	189	Buffalo	s3://bucket/img.jpg	{2,57,58,60,61}	19.028322	73.047322	2026-09-03 00:05:38.376889
2557	466	Pig	s3://bucket/img.jpg	{48,49,27,47}	31.037420	75.018651	2026-09-03 00:05:38.376889
2558	318	Cattle	s3://bucket/img.jpg	{1,34,29,31}	19.038200	72.993133	2026-09-03 00:05:38.376889
2559	393	Cattle	s3://bucket/img.jpg	{64,65,67,47,63}	9.809011	70.484559	2026-09-03 00:05:38.376889
2560	346	Cattle	s3://bucket/img.jpg	{43,44,45,46}	31.003296	75.031421	2026-09-03 00:05:38.376889
2561	361	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.998610	73.009816	2026-09-03 00:05:38.376889
2562	82	Buffalo	s3://bucket/img.jpg	{2,43,46}	16.369546	81.639265	2026-09-03 00:05:38.376889
2563	466	Pig	s3://bucket/img.jpg	{2,3,4,5,10,11}	26.018488	92.009795	2026-09-03 00:05:38.376889
2564	19	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	14.331562	73.531851	2026-09-03 00:05:38.376889
2565	488	Pig	s3://bucket/img.jpg	{2,4,5,8,9}	25.966010	92.023081	2026-09-03 00:05:38.376889
2566	487	Sheep	s3://bucket/img.jpg	{32,1,30,31}	19.012171	72.972780	2026-09-03 00:05:38.376889
2567	174	Goat	s3://bucket/img.jpg	{1,12,13,14}	30.991135	74.958952	2026-09-03 00:05:38.376889
2568	196	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.028898	92.011118	2026-09-03 00:05:38.376889
2569	13	Sheep	s3://bucket/img.jpg	{27,51,52}	30.967018	75.038589	2026-09-03 00:05:38.376889
2570	360	Pig	s3://bucket/img.jpg	{2,11,6,7}	28.469928	92.743012	2026-09-03 00:05:38.376889
2571	40	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.044735	75.021081	2026-09-03 00:05:38.376889
2572	46	Cattle	s3://bucket/img.jpg	{64,65,67,47,62}	25.504474	75.151874	2026-09-03 00:05:38.376889
2573	269	Sheep	s3://bucket/img.jpg	{28,29,31}	30.979361	74.995939	2026-09-03 00:05:38.376889
2574	297	Pig	s3://bucket/img.jpg	{1,2,3,4,10}	30.961079	74.975965	2026-09-03 00:05:38.376889
2575	493	Sheep	s3://bucket/img.jpg	{1,12,13}	11.839819	69.653383	2026-09-03 00:05:38.376889
2576	446	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.024602	72.995708	2026-09-03 00:05:38.376889
2577	55	Buffalo	s3://bucket/img.jpg	{2,44,45}	26.022113	91.978510	2026-09-03 00:05:38.376889
2578	168	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.020991	75.015254	2026-09-03 00:05:38.376889
2579	215	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	18.971995	73.011575	2026-09-03 00:05:38.376889
2580	403	Buffalo	s3://bucket/img.jpg	{64,65,62,47}	26.832795	85.844502	2026-09-03 00:05:38.376889
2581	435	Pig	s3://bucket/img.jpg	{35,60,54,55}	26.010696	92.048216	2026-09-03 00:05:38.376889
2582	33	Goat	s3://bucket/img.jpg	{50,35,47}	25.979749	91.982028	2026-09-03 00:05:38.376889
2583	186	Sheep	s3://bucket/img.jpg	{41,42,36,4}	25.963430	92.046148	2026-09-03 00:05:38.376889
2584	409	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	19.029950	73.017186	2026-09-03 00:05:38.376889
2585	480	Cattle	s3://bucket/img.jpg	{66,27,68,62}	18.984092	73.015190	2026-09-03 00:05:38.376889
2586	183	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	26.027808	91.951971	2026-09-03 00:05:38.376889
2587	105	Cattle	s3://bucket/img.jpg	{2,56,58,59,61}	26.027303	87.202790	2026-09-03 00:05:38.376889
2588	485	Pig	s3://bucket/img.jpg	{8,10,5}	30.991806	75.015215	2026-09-03 00:05:38.376889
2589	341	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	32.769496	90.555258	2026-09-03 00:05:38.376889
2590	176	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	26.040976	91.971353	2026-09-03 00:05:38.376889
2591	142	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	19.034449	73.001225	2026-09-03 00:05:38.376889
2592	170	Cattle	s3://bucket/img.jpg	{66,67,62,63}	27.219485	92.482681	2026-09-03 00:05:38.376889
2593	294	Cattle	s3://bucket/img.jpg	{24,25,26,23}	27.200627	72.430187	2026-09-03 00:05:38.376889
2594	238	Pig	s3://bucket/img.jpg	{35,27,47}	20.535042	68.862221	2026-09-03 00:05:38.376889
2595	294	Buffalo	s3://bucket/img.jpg	{67,62,47}	31.032634	74.957169	2026-09-03 00:05:38.376889
2596	419	Pig	s3://bucket/img.jpg	{35,53,54,55}	18.970089	72.959162	2026-09-03 00:05:38.376889
2597	140	Goat	s3://bucket/img.jpg	{1,13,14}	18.952548	72.985553	2026-09-03 00:05:38.376889
2598	387	Pig	s3://bucket/img.jpg	{8,11,2,10}	30.999508	75.028638	2026-09-03 00:05:38.376889
2599	281	Goat	s3://bucket/img.jpg	{35,4,38,39,40,42}	25.979564	91.970716	2026-09-03 00:05:38.376889
2600	169	Cattle	s3://bucket/img.jpg	{2,43,44,45}	31.520742	91.950063	2026-09-03 00:05:38.376889
2601	425	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.990027	74.985529	2026-09-03 00:05:38.376889
2602	31	Cattle	s3://bucket/img.jpg	{2,43,44,45,46,15}	26.025222	92.006439	2026-09-03 00:05:38.376889
2603	245	Cattle	s3://bucket/img.jpg	{3,35,52,47}	25.969881	92.026358	2026-09-03 00:05:38.376889
2604	94	Cattle	s3://bucket/img.jpg	{2,44,45,46}	18.984404	72.973094	2026-09-03 00:05:38.376889
2605	180	Pig	s3://bucket/img.jpg	{35,53,54,55}	30.997201	74.964389	2026-09-03 00:05:38.376889
2606	403	Poultry	s3://bucket/img.jpg	{20,21,6}	33.277416	71.890310	2026-09-03 00:05:38.376889
2607	119	Cattle	s3://bucket/img.jpg	{32,33,27,29,30}	30.992507	74.964823	2026-09-03 00:05:38.376889
2608	432	Sheep	s3://bucket/img.jpg	{12,13,14}	16.906286	73.719229	2026-09-03 00:05:38.376889
2609	351	Pig	s3://bucket/img.jpg	{8,1,3,6}	30.956896	74.979741	2026-09-03 00:05:38.376889
2610	415	Sheep	s3://bucket/img.jpg	{36,37,38,4,40,41}	19.015140	72.966698	2026-09-03 00:05:38.376889
2611	91	Sheep	s3://bucket/img.jpg	{4,69}	23.386768	85.208287	2026-09-03 00:05:38.376889
2612	412	Goat	s3://bucket/img.jpg	{42,35,36,37}	25.978568	92.022188	2026-09-03 00:05:38.376889
2613	364	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.964201	75.030000	2026-09-03 00:05:38.376889
2614	123	Pig	s3://bucket/img.jpg	{2,11,4,5}	26.041670	92.021050	2026-09-03 00:05:38.376889
2615	384	Sheep	s3://bucket/img.jpg	{4,69}	27.152559	70.036273	2026-09-03 00:05:38.376889
2616	262	Poultry	s3://bucket/img.jpg	{6,15,18,20,22}	18.955854	72.997184	2026-09-03 00:05:38.376889
2617	322	Cattle	s3://bucket/img.jpg	{12,13}	26.004970	91.994102	2026-09-03 00:05:38.376889
2618	254	Poultry	s3://bucket/img.jpg	{18,19,20,15}	19.042075	72.968468	2026-09-03 00:05:38.376889
2619	334	Cattle	s3://bucket/img.jpg	{32,33,34,1,27,28}	26.016769	91.966850	2026-09-03 00:05:38.376889
2620	177	Cattle	s3://bucket/img.jpg	{27,52,30}	26.042051	92.015162	2026-09-03 00:05:38.376889
2621	181	Cattle	s3://bucket/img.jpg	{32,1,27,31}	25.982787	91.993688	2026-09-03 00:05:38.376889
2622	474	Sheep	s3://bucket/img.jpg	{1,12,13,14}	18.992895	73.006779	2026-09-03 00:05:38.376889
2623	395	Cattle	s3://bucket/img.jpg	{24,25,26,23}	19.042896	72.999538	2026-09-03 00:05:38.376889
2624	369	Poultry	s3://bucket/img.jpg	{12,20,21}	18.977713	72.968974	2026-09-03 00:05:38.376889
2625	101	Buffalo	s3://bucket/img.jpg	{2,44,45}	13.196082	72.782031	2026-09-03 00:05:38.376889
2626	419	Cattle	s3://bucket/img.jpg	{64,66,35,47}	25.958258	91.989602	2026-09-03 00:05:38.376889
2627	380	Pig	s3://bucket/img.jpg	{1,3,4,5,6,8}	31.040464	75.026249	2026-09-03 00:05:38.376889
2628	494	Cattle	s3://bucket/img.jpg	{64,65,66,35,62}	18.972244	73.031500	2026-09-03 00:05:38.376889
2629	108	Goat	s3://bucket/img.jpg	{1,12,13,14}	31.029999	75.004488	2026-09-03 00:05:38.376889
2630	155	Sheep	s3://bucket/img.jpg	{32,1,34,33,29,30}	31.013839	75.026128	2026-09-03 00:05:38.376889
2631	39	Pig	s3://bucket/img.jpg	{35,37,53,54,55}	26.026003	92.004704	2026-09-03 00:05:38.376889
2632	446	Cattle	s3://bucket/img.jpg	{47,48,49,50,52,27}	18.316988	71.068540	2026-09-03 00:05:38.376889
2633	322	Pig	s3://bucket/img.jpg	{9,10,6}	31.041950	74.992584	2026-09-03 00:05:38.376889
2634	356	Sheep	s3://bucket/img.jpg	{1,12,13}	19.041012	72.953985	2026-09-03 00:05:38.376889
2635	465	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.021656	75.018698	2026-09-03 00:05:38.376889
2636	350	Cattle	s3://bucket/img.jpg	{24,25,23}	25.989436	91.979106	2026-09-03 00:05:38.376889
2637	147	Buffalo	s3://bucket/img.jpg	{67,35,68,63}	24.775308	92.656462	2026-09-03 00:05:38.376889
2638	249	Buffalo	s3://bucket/img.jpg	{2,57,58,59,60,61}	26.626335	82.051274	2026-09-03 00:05:38.376889
2639	490	Cattle	s3://bucket/img.jpg	{1,12,13,14}	9.000795	77.855513	2026-09-03 00:05:38.376889
2640	31	Sheep	s3://bucket/img.jpg	{40,4,37,38}	30.982734	74.972746	2026-09-03 00:05:38.376889
2641	300	Sheep	s3://bucket/img.jpg	{56,57,58,59,60}	26.038606	91.987264	2026-09-03 00:05:38.376889
2642	212	Sheep	s3://bucket/img.jpg	{35,36,38,39,42}	13.889116	77.396400	2026-09-03 00:05:38.376889
2643	414	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.030902	91.998579	2026-09-03 00:05:38.376889
2644	150	Buffalo	s3://bucket/img.jpg	{67,62,63}	27.173757	76.037183	2026-09-03 00:05:38.376889
2645	143	Cattle	s3://bucket/img.jpg	{24,25,23}	19.015843	73.041118	2026-09-03 00:05:38.376889
2646	106	Sheep	s3://bucket/img.jpg	{12,14}	19.020215	72.963081	2026-09-03 00:05:38.376889
2647	129	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	31.012993	74.983324	2026-09-03 00:05:38.376889
2648	97	Cattle	s3://bucket/img.jpg	{64,66,67,62}	30.996222	74.999890	2026-09-03 00:05:38.376889
2649	77	Cattle	s3://bucket/img.jpg	{27,28,29,30}	25.872962	76.973781	2026-09-03 00:05:38.376889
2650	115	Cattle	s3://bucket/img.jpg	{1,34,33,28,29,31}	18.988682	73.018219	2026-09-03 00:05:38.376889
2651	133	Buffalo	s3://bucket/img.jpg	{64,66,35,67,68,63}	25.973921	91.988655	2026-09-03 00:05:38.376889
2652	368	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.979079	73.000758	2026-09-03 00:05:38.376889
2653	336	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.040476	92.016525	2026-09-03 00:05:38.376889
2654	490	Pig	s3://bucket/img.jpg	{5,6,8,9,10}	19.000609	72.993472	2026-09-03 00:05:38.376889
2655	494	Sheep	s3://bucket/img.jpg	{2,57,58,59,60,61}	19.007841	73.024335	2026-09-03 00:05:38.376889
2656	184	Cattle	s3://bucket/img.jpg	{27,28,29,30}	13.099918	81.069503	2026-09-03 00:05:38.376889
2657	101	Cattle	s3://bucket/img.jpg	{32,1,29,30,31}	26.034081	92.012851	2026-09-03 00:05:38.376889
2658	197	Cattle	s3://bucket/img.jpg	{66,67,68,63}	12.307209	85.023144	2026-09-03 00:05:38.376889
2659	140	Cattle	s3://bucket/img.jpg	{24,25,26,23}	29.638435	71.551491	2026-09-03 00:05:38.376889
2660	486	Goat	s3://bucket/img.jpg	{1,12,14}	18.974179	72.958094	2026-09-03 00:05:38.376889
2661	383	Pig	s3://bucket/img.jpg	{1,2,6,7,8,9}	16.684844	88.954342	2026-09-03 00:05:38.376889
2662	321	Goat	s3://bucket/img.jpg	{4,69}	30.979257	75.045277	2026-09-03 00:05:38.376889
2663	476	Pig	s3://bucket/img.jpg	{3,35,53,54,55}	29.745743	89.556762	2026-09-03 00:05:38.376889
2664	359	Pig	s3://bucket/img.jpg	{2,3,5,7,8,11}	25.953882	92.033427	2026-09-03 00:05:38.376889
2665	116	Cattle	s3://bucket/img.jpg	{64,66,35,68,47,62}	25.954751	91.997304	2026-09-03 00:05:38.376889
2666	98	Sheep	s3://bucket/img.jpg	{4,69}	11.147585	85.923712	2026-09-03 00:05:38.376889
2667	267	Cattle	s3://bucket/img.jpg	{34,27,28,29,31}	24.435634	88.314835	2026-09-03 00:05:38.376889
2668	490	Sheep	s3://bucket/img.jpg	{35,4,69}	31.003834	74.957952	2026-09-03 00:05:38.376889
2669	78	Cattle	s3://bucket/img.jpg	{24,26,23}	31.027187	74.952139	2026-09-03 00:05:38.376889
2670	39	Goat	s3://bucket/img.jpg	{4,69}	25.995012	91.952918	2026-09-03 00:05:38.376889
2671	428	Goat	s3://bucket/img.jpg	{40,41,35,38}	31.000856	75.016763	2026-09-03 00:05:38.376889
2672	67	Cattle	s3://bucket/img.jpg	{25,26,23}	15.052630	74.032680	2026-09-03 00:05:38.376889
2673	495	Sheep	s3://bucket/img.jpg	{2,56,57,58,60}	29.854651	88.300690	2026-09-03 00:05:38.376889
2674	176	Pig	s3://bucket/img.jpg	{1,3,4,9}	15.654569	82.055094	2026-09-03 00:05:38.376889
2675	219	Goat	s3://bucket/img.jpg	{12,13,14}	12.533798	69.582969	2026-09-03 00:05:38.376889
2676	59	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.973760	75.041777	2026-09-03 00:05:38.376889
2677	469	Cattle	s3://bucket/img.jpg	{34,27,28,31}	23.380240	73.713471	2026-09-03 00:05:38.376889
2678	319	Sheep	s3://bucket/img.jpg	{2,56,57,59,61}	19.049860	72.956596	2026-09-03 00:05:38.376889
2679	53	Sheep	s3://bucket/img.jpg	{41,35,38}	30.954443	75.043149	2026-09-03 00:05:38.376889
2680	439	Sheep	s3://bucket/img.jpg	{36,37,38,39,40,41,42}	18.956811	72.985009	2026-09-03 00:05:38.376889
2681	451	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.969268	91.953367	2026-09-03 00:05:38.376889
2682	448	Sheep	s3://bucket/img.jpg	{32,33,34,1,28,31}	31.017084	74.974333	2026-09-03 00:05:38.376889
2683	357	Buffalo	s3://bucket/img.jpg	{51,43,45,46}	18.268389	71.799135	2026-09-03 00:05:38.376889
2684	261	Goat	s3://bucket/img.jpg	{4,69}	26.014607	91.963982	2026-09-03 00:05:38.376889
2685	347	Pig	s3://bucket/img.jpg	{35,53,54,55}	19.016185	73.023844	2026-09-03 00:05:38.376889
2686	136	Buffalo	s3://bucket/img.jpg	{56,58,60}	31.038212	74.963663	2026-09-03 00:05:38.376889
2687	132	Cattle	s3://bucket/img.jpg	{1,34,30,33}	18.997396	72.988039	2026-09-03 00:05:38.376889
2688	179	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.020752	71.009459	2026-09-03 00:05:38.376889
2689	110	Sheep	s3://bucket/img.jpg	{35,50,51,27,30}	25.996207	92.032652	2026-09-03 00:05:38.376889
2690	414	Buffalo	s3://bucket/img.jpg	{2,44,45,46}	8.732748	84.293462	2026-09-03 00:05:38.376889
2691	385	Sheep	s3://bucket/img.jpg	{1,12,13}	25.698086	92.671680	2026-09-03 00:05:38.376889
2692	241	Goat	s3://bucket/img.jpg	{35,36,37,38,39,42}	18.955424	73.042219	2026-09-03 00:05:38.376889
2693	235	Cattle	s3://bucket/img.jpg	{24,25,26,23}	25.999470	92.013330	2026-09-03 00:05:38.376889
2694	160	Sheep	s3://bucket/img.jpg	{36,37,4,38,40}	25.711221	80.543753	2026-09-03 00:05:38.376889
2695	156	Cattle	s3://bucket/img.jpg	{51,27,52,47}	8.490415	80.492005	2026-09-03 00:05:38.376889
2696	401	Sheep	s3://bucket/img.jpg	{35,37,38,40,41,42}	26.011273	92.002419	2026-09-03 00:05:38.376889
2697	91	Goat	s3://bucket/img.jpg	{4,36,38,40,41,42}	30.969451	74.955992	2026-09-03 00:05:38.376889
2698	55	Goat	s3://bucket/img.jpg	{1,12,13,14}	25.972750	91.962895	2026-09-03 00:05:38.376889
2699	257	Cattle	s3://bucket/img.jpg	{24,26,3,23}	30.990835	74.970625	2026-09-03 00:05:38.376889
2700	448	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	14.656515	92.378916	2026-09-03 00:05:38.376889
2701	240	Sheep	s3://bucket/img.jpg	{1,12,13,14}	30.978263	75.001687	2026-09-03 00:05:38.376889
2702	301	Cattle	s3://bucket/img.jpg	{1,12,13,14}	17.656601	80.355998	2026-09-03 00:05:38.376889
2703	358	Cattle	s3://bucket/img.jpg	{64,65,62,47}	30.955064	75.032361	2026-09-03 00:05:38.376889
2704	81	Goat	s3://bucket/img.jpg	{4,69}	18.976565	73.046129	2026-09-03 00:05:38.376889
2705	183	Cattle	s3://bucket/img.jpg	{59,58,2}	19.041721	72.952961	2026-09-03 00:05:38.376889
2706	331	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	25.999505	92.037604	2026-09-03 00:05:38.376889
2707	472	Pig	s3://bucket/img.jpg	{35,48,49,50,51,27}	16.274802	89.026263	2026-09-03 00:05:38.376889
2708	347	Buffalo	s3://bucket/img.jpg	{2,56,57,58,59,61}	25.952035	91.950245	2026-09-03 00:05:38.376889
2709	49	Sheep	s3://bucket/img.jpg	{12,14}	29.712029	80.930314	2026-09-03 00:05:38.376889
2710	355	Cattle	s3://bucket/img.jpg	{11,56,58,59,60}	31.008062	75.015873	2026-09-03 00:05:38.376889
2711	196	Cattle	s3://bucket/img.jpg	{24,25,26,23}	31.475065	70.132081	2026-09-03 00:05:38.376889
2712	212	Buffalo	s3://bucket/img.jpg	{2,56,58,59,60,61}	31.849408	87.491792	2026-09-03 00:05:38.376889
2713	354	Cattle	s3://bucket/img.jpg	{48,27,52,47}	26.004035	91.984564	2026-09-03 00:05:38.376889
2714	277	Pig	s3://bucket/img.jpg	{35,53,54,55}	8.367848	82.590814	2026-09-03 00:05:38.376889
2715	82	Cattle	s3://bucket/img.jpg	{64,66,67,35,68,14,63}	19.000784	73.014629	2026-09-03 00:05:38.376889
2716	490	Cattle	s3://bucket/img.jpg	{64,67,68,62,63}	18.976442	73.008539	2026-09-03 00:05:38.376889
2717	353	Sheep	s3://bucket/img.jpg	{35,4,36,37,38,42}	19.451350	92.380681	2026-09-03 00:05:38.376889
2718	388	Goat	s3://bucket/img.jpg	{35,47,49,51,27}	22.901381	71.347947	2026-09-03 00:05:38.376889
2719	387	Cattle	s3://bucket/img.jpg	{2,43,44,45,46}	31.016211	75.040339	2026-09-03 00:05:38.376889
2720	277	Pig	s3://bucket/img.jpg	{35,53,54}	13.289854	79.091568	2026-09-03 00:05:38.376889
2721	363	Pig	s3://bucket/img.jpg	{48,50,51,4}	26.047920	91.992793	2026-09-03 00:05:38.376889
2722	383	Goat	s3://bucket/img.jpg	{1,12,13,14}	19.018345	73.013728	2026-09-03 00:05:38.376889
2723	101	Sheep	s3://bucket/img.jpg	{1,12,13,14}	10.708302	75.876741	2026-09-03 00:05:38.376889
2724	117	Pig	s3://bucket/img.jpg	{35,53,54,55}	26.003648	92.015155	2026-09-03 00:05:38.376889
2725	273	Cattle	s3://bucket/img.jpg	{32,27,28,29,30}	30.956419	74.993788	2026-09-03 00:05:38.376889
2726	109	Cattle	s3://bucket/img.jpg	{24,25,26,23}	26.040313	92.036046	2026-09-03 00:05:38.376889
2727	350	Sheep	s3://bucket/img.jpg	{32,1,27,29,30,31}	26.047925	91.977273	2026-09-03 00:05:38.376889
2728	391	Goat	s3://bucket/img.jpg	{4,69}	21.044565	69.391340	2026-09-03 00:05:38.376889
2729	182	Cattle	s3://bucket/img.jpg	{51,27,52}	23.200487	78.484116	2026-09-03 00:05:38.376889
2730	227	Sheep	s3://bucket/img.jpg	{35,37,38,39,41,42}	26.048235	91.988832	2026-09-03 00:05:38.376889
2731	484	Sheep	s3://bucket/img.jpg	{4,69}	31.986450	90.374883	2026-09-03 00:05:38.376889
2732	105	Sheep	s3://bucket/img.jpg	{56,57,58,2}	20.629085	72.009234	2026-09-03 00:05:38.376889
2733	436	Goat	s3://bucket/img.jpg	{24,4,69}	26.020239	92.001956	2026-09-03 00:05:38.376889
2734	310	Buffalo	s3://bucket/img.jpg	{64,66,35,68,63}	18.553151	69.959228	2026-09-03 00:05:38.376889
2735	366	Sheep	s3://bucket/img.jpg	{35,36,4,40,41}	12.764823	89.744272	2026-09-03 00:05:38.376889
2736	380	Buffalo	s3://bucket/img.jpg	{2,43,44,46}	18.985973	72.995103	2026-09-03 00:05:38.376889
2737	410	Pig	s3://bucket/img.jpg	{35,53,54,55}	20.027886	91.181649	2026-09-03 00:05:38.376889
2738	6	Buffalo	s3://bucket/img.jpg	{2,43,44,45,46}	24.387836	69.844587	2026-09-03 00:05:38.376889
2739	410	Cattle	s3://bucket/img.jpg	{64,66,35,68}	26.027602	91.969912	2026-09-03 00:05:38.376889
2740	108	Cattle	s3://bucket/img.jpg	{47,48,50,51,52,30}	31.044672	74.957591	2026-09-03 00:05:38.376889
2741	305	Cattle	s3://bucket/img.jpg	{12,13,14}	30.980974	75.042585	2026-09-03 00:05:38.376889
2742	223	Sheep	s3://bucket/img.jpg	{2,56,57,58,59}	20.557863	72.576535	2026-09-03 00:05:38.376889
2743	419	Cattle	s3://bucket/img.jpg	{24,25,26,23}	30.965957	74.988467	2026-09-03 00:05:38.376889
2744	399	Cattle	s3://bucket/img.jpg	{24,25,26,23}	18.982503	72.975223	2026-09-03 00:05:38.376889
2745	488	Buffalo	s3://bucket/img.jpg	{64,65,68,63}	30.984568	75.021287	2026-09-03 00:05:38.376889
2746	85	Cattle	s3://bucket/img.jpg	{24,25,26,23}	32.468538	83.020992	2026-09-03 00:05:38.376889
2747	339	Pig	s3://bucket/img.jpg	{35,53,54}	30.965642	75.001599	2026-09-03 00:05:38.376889
2748	32	Cattle	s3://bucket/img.jpg	{64,66,68,62,63}	19.016087	73.002622	2026-09-03 00:05:38.376889
2749	131	Pig	s3://bucket/img.jpg	{8,9,3,7}	15.089187	91.297978	2026-09-03 00:05:38.376889
2750	200	Pig	s3://bucket/img.jpg	{35,53,54,55}	31.037554	75.010398	2026-09-03 00:05:38.376889
2751	304	Pig	s3://bucket/img.jpg	{9,2,4,5}	18.964284	72.982772	2026-09-03 00:05:38.376889
2752	171	Cattle	s3://bucket/img.jpg	{35,49,50,27,30}	26.018836	92.027654	2026-09-03 00:05:38.376889
2753	497	Sheep	s3://bucket/img.jpg	{2,57,58,59,60,61}	26.019014	92.022612	2026-09-03 00:05:38.376889
2754	9	Buffalo	s3://bucket/img.jpg	{64,65,67,35,47,62}	33.594872	80.802355	2026-09-03 00:05:38.376889
2755	93	Cattle	s3://bucket/img.jpg	{2,41,56,59,60,61}	31.004766	74.974906	2026-09-03 00:05:38.376889
2756	485	Poultry	s3://bucket/img.jpg	{12,18,19,20,21}	31.031402	75.019965	2026-09-03 00:05:38.376889
\.


--
-- Data for Name: lab_reports; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.lab_reports (lab_report_id, report_id, lab_technician_id, confirmed_disease_id, test_method, test_results, is_final_truth, used_in_training, verified_at) FROM stdin;
551	1757	552	5	\N	\N	t	f	2026-09-03 00:05:38.376889
552	1758	568	6	\N	\N	t	f	2026-09-03 00:05:38.376889
553	1760	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
554	1764	556	9	\N	\N	t	f	2026-09-03 00:05:38.376889
555	1765	558	4	\N	\N	t	f	2026-09-03 00:05:38.376889
556	1766	569	3	\N	\N	t	f	2026-09-03 00:05:38.376889
557	1772	556	5	\N	\N	t	f	2026-09-03 00:05:38.376889
558	1773	570	1	\N	\N	t	f	2026-09-03 00:05:38.376889
559	1775	556	12	\N	\N	t	f	2026-09-03 00:05:38.376889
560	1776	558	10	\N	\N	t	f	2026-09-03 00:05:38.376889
561	1779	553	11	\N	\N	t	f	2026-09-03 00:05:38.376889
562	1783	556	12	\N	\N	t	f	2026-09-03 00:05:38.376889
563	1787	565	10	\N	\N	t	f	2026-09-03 00:05:38.376889
564	1788	566	7	\N	\N	t	f	2026-09-03 00:05:38.376889
565	1790	566	7	\N	\N	t	f	2026-09-03 00:05:38.376889
566	1792	564	5	\N	\N	t	f	2026-09-03 00:05:38.376889
567	1793	566	4	\N	\N	t	f	2026-09-03 00:05:38.376889
568	1799	567	6	\N	\N	t	f	2026-09-03 00:05:38.376889
569	1801	569	11	\N	\N	t	f	2026-09-03 00:05:38.376889
570	1803	556	3	\N	\N	t	f	2026-09-03 00:05:38.376889
571	1804	563	11	\N	\N	t	f	2026-09-03 00:05:38.376889
572	1807	564	5	\N	\N	t	f	2026-09-03 00:05:38.376889
573	1808	569	5	\N	\N	t	f	2026-09-03 00:05:38.376889
574	1809	564	10	\N	\N	t	f	2026-09-03 00:05:38.376889
575	1810	553	5	\N	\N	t	f	2026-09-03 00:05:38.376889
576	1811	566	5	\N	\N	t	f	2026-09-03 00:05:38.376889
577	1812	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
578	1814	552	10	\N	\N	t	f	2026-09-03 00:05:38.376889
579	1816	553	3	\N	\N	t	f	2026-09-03 00:05:38.376889
580	1820	555	4	\N	\N	t	f	2026-09-03 00:05:38.376889
581	1821	568	3	\N	\N	t	f	2026-09-03 00:05:38.376889
582	1824	568	10	\N	\N	t	f	2026-09-03 00:05:38.376889
583	1827	568	9	\N	\N	t	f	2026-09-03 00:05:38.376889
584	1828	567	5	\N	\N	t	f	2026-09-03 00:05:38.376889
585	1829	555	9	\N	\N	t	f	2026-09-03 00:05:38.376889
586	1833	551	10	\N	\N	t	f	2026-09-03 00:05:38.376889
587	1837	553	10	\N	\N	t	f	2026-09-03 00:05:38.376889
588	1838	555	2	\N	\N	t	f	2026-09-03 00:05:38.376889
589	1842	560	2	\N	\N	t	f	2026-09-03 00:05:38.376889
590	1844	569	3	\N	\N	t	f	2026-09-03 00:05:38.376889
591	1847	555	6	\N	\N	t	f	2026-09-03 00:05:38.376889
592	1849	562	10	\N	\N	t	f	2026-09-03 00:05:38.376889
593	1852	565	2	\N	\N	t	f	2026-09-03 00:05:38.376889
594	1860	567	4	\N	\N	t	f	2026-09-03 00:05:38.376889
595	1861	556	10	\N	\N	t	f	2026-09-03 00:05:38.376889
596	1862	555	9	\N	\N	t	f	2026-09-03 00:05:38.376889
597	1864	551	10	\N	\N	t	f	2026-09-03 00:05:38.376889
598	1866	567	3	\N	\N	t	f	2026-09-03 00:05:38.376889
599	1871	563	5	\N	\N	t	f	2026-09-03 00:05:38.376889
600	1872	562	2	\N	\N	t	f	2026-09-03 00:05:38.376889
601	1873	569	3	\N	\N	t	f	2026-09-03 00:05:38.376889
602	1876	552	7	\N	\N	t	f	2026-09-03 00:05:38.376889
603	1877	558	7	\N	\N	t	f	2026-09-03 00:05:38.376889
604	1883	565	8	\N	\N	t	f	2026-09-03 00:05:38.376889
605	1885	555	8	\N	\N	t	f	2026-09-03 00:05:38.376889
606	1886	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
607	1887	561	8	\N	\N	t	f	2026-09-03 00:05:38.376889
608	1889	570	9	\N	\N	t	f	2026-09-03 00:05:38.376889
609	1896	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
610	1900	562	11	\N	\N	t	f	2026-09-03 00:05:38.376889
611	1903	556	4	\N	\N	t	f	2026-09-03 00:05:38.376889
612	1905	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
613	1908	563	2	\N	\N	t	f	2026-09-03 00:05:38.376889
614	1910	560	3	\N	\N	t	f	2026-09-03 00:05:38.376889
615	1912	559	1	\N	\N	t	f	2026-09-03 00:05:38.376889
616	1913	552	2	\N	\N	t	f	2026-09-03 00:05:38.376889
617	1915	554	8	\N	\N	t	f	2026-09-03 00:05:38.376889
618	1918	551	5	\N	\N	t	f	2026-09-03 00:05:38.376889
619	1921	553	7	\N	\N	t	f	2026-09-03 00:05:38.376889
620	1923	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
621	1925	551	8	\N	\N	t	f	2026-09-03 00:05:38.376889
622	1927	553	5	\N	\N	t	f	2026-09-03 00:05:38.376889
623	1928	557	5	\N	\N	t	f	2026-09-03 00:05:38.376889
624	1930	555	4	\N	\N	t	f	2026-09-03 00:05:38.376889
625	1933	559	3	\N	\N	t	f	2026-09-03 00:05:38.376889
626	1936	551	10	\N	\N	t	f	2026-09-03 00:05:38.376889
627	1937	566	8	\N	\N	t	f	2026-09-03 00:05:38.376889
628	1938	561	4	\N	\N	t	f	2026-09-03 00:05:38.376889
629	1939	562	10	\N	\N	t	f	2026-09-03 00:05:38.376889
630	1940	568	2	\N	\N	t	f	2026-09-03 00:05:38.376889
631	1943	566	4	\N	\N	t	f	2026-09-03 00:05:38.376889
632	1944	569	5	\N	\N	t	f	2026-09-03 00:05:38.376889
633	1945	558	8	\N	\N	t	f	2026-09-03 00:05:38.376889
634	1946	559	4	\N	\N	t	f	2026-09-03 00:05:38.376889
635	1949	555	9	\N	\N	t	f	2026-09-03 00:05:38.376889
636	1950	551	11	\N	\N	t	f	2026-09-03 00:05:38.376889
637	1953	568	7	\N	\N	t	f	2026-09-03 00:05:38.376889
638	1954	570	6	\N	\N	t	f	2026-09-03 00:05:38.376889
639	1957	561	12	\N	\N	t	f	2026-09-03 00:05:38.376889
640	1959	561	9	\N	\N	t	f	2026-09-03 00:05:38.376889
641	1960	562	1	\N	\N	t	f	2026-09-03 00:05:38.376889
642	1961	557	12	\N	\N	t	f	2026-09-03 00:05:38.376889
643	1963	556	10	\N	\N	t	f	2026-09-03 00:05:38.376889
644	1965	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
645	1966	563	1	\N	\N	t	f	2026-09-03 00:05:38.376889
646	1970	560	6	\N	\N	t	f	2026-09-03 00:05:38.376889
647	1972	563	7	\N	\N	t	f	2026-09-03 00:05:38.376889
648	1974	553	9	\N	\N	t	f	2026-09-03 00:05:38.376889
649	1977	563	7	\N	\N	t	f	2026-09-03 00:05:38.376889
650	1978	568	2	\N	\N	t	f	2026-09-03 00:05:38.376889
651	1979	570	11	\N	\N	t	f	2026-09-03 00:05:38.376889
652	1983	558	6	\N	\N	t	f	2026-09-03 00:05:38.376889
653	1984	559	12	\N	\N	t	f	2026-09-03 00:05:38.376889
654	1987	560	3	\N	\N	t	f	2026-09-03 00:05:38.376889
655	1988	565	5	\N	\N	t	f	2026-09-03 00:05:38.376889
656	1989	554	5	\N	\N	t	f	2026-09-03 00:05:38.376889
657	1999	562	12	\N	\N	t	f	2026-09-03 00:05:38.376889
658	2000	552	10	\N	\N	t	f	2026-09-03 00:05:38.376889
659	2002	569	1	\N	\N	t	f	2026-09-03 00:05:38.376889
660	2003	554	12	\N	\N	t	f	2026-09-03 00:05:38.376889
661	2004	552	8	\N	\N	t	f	2026-09-03 00:05:38.376889
662	2005	568	9	\N	\N	t	f	2026-09-03 00:05:38.376889
663	2008	568	8	\N	\N	t	f	2026-09-03 00:05:38.376889
664	2014	562	12	\N	\N	t	f	2026-09-03 00:05:38.376889
665	2015	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
666	2017	568	10	\N	\N	t	f	2026-09-03 00:05:38.376889
667	2022	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
668	2026	561	4	\N	\N	t	f	2026-09-03 00:05:38.376889
669	2028	569	12	\N	\N	t	f	2026-09-03 00:05:38.376889
670	2031	565	11	\N	\N	t	f	2026-09-03 00:05:38.376889
671	2032	562	3	\N	\N	t	f	2026-09-03 00:05:38.376889
672	2034	565	3	\N	\N	t	f	2026-09-03 00:05:38.376889
673	2037	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
674	2039	557	2	\N	\N	t	f	2026-09-03 00:05:38.376889
675	2040	562	7	\N	\N	t	f	2026-09-03 00:05:38.376889
676	2046	560	8	\N	\N	t	f	2026-09-03 00:05:38.376889
677	2055	568	5	\N	\N	t	f	2026-09-03 00:05:38.376889
678	2056	569	10	\N	\N	t	f	2026-09-03 00:05:38.376889
679	2059	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
680	2060	557	2	\N	\N	t	f	2026-09-03 00:05:38.376889
681	2065	561	1	\N	\N	t	f	2026-09-03 00:05:38.376889
682	2066	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
683	2067	563	2	\N	\N	t	f	2026-09-03 00:05:38.376889
684	2068	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
685	2071	559	1	\N	\N	t	f	2026-09-03 00:05:38.376889
686	2078	569	2	\N	\N	t	f	2026-09-03 00:05:38.376889
687	2089	557	5	\N	\N	t	f	2026-09-03 00:05:38.376889
688	2091	554	3	\N	\N	t	f	2026-09-03 00:05:38.376889
689	2093	551	1	\N	\N	t	f	2026-09-03 00:05:38.376889
690	2094	551	9	\N	\N	t	f	2026-09-03 00:05:38.376889
691	2095	562	8	\N	\N	t	f	2026-09-03 00:05:38.376889
692	2099	561	10	\N	\N	t	f	2026-09-03 00:05:38.376889
693	2104	569	1	\N	\N	t	f	2026-09-03 00:05:38.376889
694	2107	555	9	\N	\N	t	f	2026-09-03 00:05:38.376889
695	2108	567	3	\N	\N	t	f	2026-09-03 00:05:38.376889
696	2111	551	12	\N	\N	t	f	2026-09-03 00:05:38.376889
697	2113	569	8	\N	\N	t	f	2026-09-03 00:05:38.376889
698	2115	554	7	\N	\N	t	f	2026-09-03 00:05:38.376889
699	2116	564	12	\N	\N	t	f	2026-09-03 00:05:38.376889
700	2120	568	2	\N	\N	t	f	2026-09-03 00:05:38.376889
701	2121	570	7	\N	\N	t	f	2026-09-03 00:05:38.376889
702	2122	561	2	\N	\N	t	f	2026-09-03 00:05:38.376889
703	2125	568	3	\N	\N	t	f	2026-09-03 00:05:38.376889
704	2130	568	7	\N	\N	t	f	2026-09-03 00:05:38.376889
705	2131	568	6	\N	\N	t	f	2026-09-03 00:05:38.376889
706	2133	556	12	\N	\N	t	f	2026-09-03 00:05:38.376889
707	2134	557	1	\N	\N	t	f	2026-09-03 00:05:38.376889
708	2137	551	10	\N	\N	t	f	2026-09-03 00:05:38.376889
709	2140	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
710	2141	566	4	\N	\N	t	f	2026-09-03 00:05:38.376889
711	2142	564	11	\N	\N	t	f	2026-09-03 00:05:38.376889
712	2144	564	7	\N	\N	t	f	2026-09-03 00:05:38.376889
713	2145	569	1	\N	\N	t	f	2026-09-03 00:05:38.376889
714	2147	562	5	\N	\N	t	f	2026-09-03 00:05:38.376889
715	2149	568	8	\N	\N	t	f	2026-09-03 00:05:38.376889
716	2150	552	3	\N	\N	t	f	2026-09-03 00:05:38.376889
717	2151	568	5	\N	\N	t	f	2026-09-03 00:05:38.376889
718	2155	566	5	\N	\N	t	f	2026-09-03 00:05:38.376889
719	2157	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
720	2161	566	4	\N	\N	t	f	2026-09-03 00:05:38.376889
721	2163	554	3	\N	\N	t	f	2026-09-03 00:05:38.376889
722	2169	557	11	\N	\N	t	f	2026-09-03 00:05:38.376889
723	2175	560	1	\N	\N	t	f	2026-09-03 00:05:38.376889
724	2178	556	9	\N	\N	t	f	2026-09-03 00:05:38.376889
725	2181	553	1	\N	\N	t	f	2026-09-03 00:05:38.376889
726	2182	563	6	\N	\N	t	f	2026-09-03 00:05:38.376889
727	2187	563	3	\N	\N	t	f	2026-09-03 00:05:38.376889
728	2189	569	9	\N	\N	t	f	2026-09-03 00:05:38.376889
729	2190	554	4	\N	\N	t	f	2026-09-03 00:05:38.376889
730	2195	566	8	\N	\N	t	f	2026-09-03 00:05:38.376889
731	2196	563	12	\N	\N	t	f	2026-09-03 00:05:38.376889
732	2199	554	6	\N	\N	t	f	2026-09-03 00:05:38.376889
733	2202	553	8	\N	\N	t	f	2026-09-03 00:05:38.376889
734	2203	554	1	\N	\N	t	f	2026-09-03 00:05:38.376889
735	2209	557	6	\N	\N	t	f	2026-09-03 00:05:38.376889
736	2210	562	10	\N	\N	t	f	2026-09-03 00:05:38.376889
737	2212	566	2	\N	\N	t	f	2026-09-03 00:05:38.376889
738	2214	553	2	\N	\N	t	f	2026-09-03 00:05:38.376889
739	2215	560	10	\N	\N	t	f	2026-09-03 00:05:38.376889
740	2217	553	6	\N	\N	t	f	2026-09-03 00:05:38.376889
741	2218	556	12	\N	\N	t	f	2026-09-03 00:05:38.376889
742	2220	562	7	\N	\N	t	f	2026-09-03 00:05:38.376889
743	2221	551	10	\N	\N	t	f	2026-09-03 00:05:38.376889
744	2222	562	3	\N	\N	t	f	2026-09-03 00:05:38.376889
745	2229	565	11	\N	\N	t	f	2026-09-03 00:05:38.376889
746	2236	569	4	\N	\N	t	f	2026-09-03 00:05:38.376889
747	2237	560	1	\N	\N	t	f	2026-09-03 00:05:38.376889
748	2238	551	4	\N	\N	t	f	2026-09-03 00:05:38.376889
749	2240	552	2	\N	\N	t	f	2026-09-03 00:05:38.376889
750	2242	568	2	\N	\N	t	f	2026-09-03 00:05:38.376889
751	2246	565	7	\N	\N	t	f	2026-09-03 00:05:38.376889
752	2250	559	4	\N	\N	t	f	2026-09-03 00:05:38.376889
753	2254	559	8	\N	\N	t	f	2026-09-03 00:05:38.376889
754	2255	566	12	\N	\N	t	f	2026-09-03 00:05:38.376889
755	2257	563	8	\N	\N	t	f	2026-09-03 00:05:38.376889
756	2265	552	8	\N	\N	t	f	2026-09-03 00:05:38.376889
757	2266	563	10	\N	\N	t	f	2026-09-03 00:05:38.376889
758	2269	556	8	\N	\N	t	f	2026-09-03 00:05:38.376889
759	2273	558	12	\N	\N	t	f	2026-09-03 00:05:38.376889
760	2279	553	10	\N	\N	t	f	2026-09-03 00:05:38.376889
761	2280	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
762	2281	558	11	\N	\N	t	f	2026-09-03 00:05:38.376889
763	2282	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
764	2283	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
765	2285	560	1	\N	\N	t	f	2026-09-03 00:05:38.376889
766	2288	561	8	\N	\N	t	f	2026-09-03 00:05:38.376889
767	2289	552	3	\N	\N	t	f	2026-09-03 00:05:38.376889
768	2293	558	7	\N	\N	t	f	2026-09-03 00:05:38.376889
769	2298	566	12	\N	\N	t	f	2026-09-03 00:05:38.376889
770	2301	557	6	\N	\N	t	f	2026-09-03 00:05:38.376889
771	2303	562	5	\N	\N	t	f	2026-09-03 00:05:38.376889
772	2305	551	5	\N	\N	t	f	2026-09-03 00:05:38.376889
773	2306	558	2	\N	\N	t	f	2026-09-03 00:05:38.376889
774	2307	568	5	\N	\N	t	f	2026-09-03 00:05:38.376889
775	2310	555	8	\N	\N	t	f	2026-09-03 00:05:38.376889
776	2311	559	2	\N	\N	t	f	2026-09-03 00:05:38.376889
777	2312	558	7	\N	\N	t	f	2026-09-03 00:05:38.376889
778	2313	554	3	\N	\N	t	f	2026-09-03 00:05:38.376889
779	2314	557	9	\N	\N	t	f	2026-09-03 00:05:38.376889
780	2317	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
781	2318	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
782	2327	553	5	\N	\N	t	f	2026-09-03 00:05:38.376889
783	2331	553	5	\N	\N	t	f	2026-09-03 00:05:38.376889
784	2336	567	4	\N	\N	t	f	2026-09-03 00:05:38.376889
785	2340	556	5	\N	\N	t	f	2026-09-03 00:05:38.376889
786	2343	560	1	\N	\N	t	f	2026-09-03 00:05:38.376889
787	2346	565	9	\N	\N	t	f	2026-09-03 00:05:38.376889
788	2347	553	7	\N	\N	t	f	2026-09-03 00:05:38.376889
789	2349	565	4	\N	\N	t	f	2026-09-03 00:05:38.376889
790	2350	565	3	\N	\N	t	f	2026-09-03 00:05:38.376889
791	2353	567	12	\N	\N	t	f	2026-09-03 00:05:38.376889
792	2356	569	8	\N	\N	t	f	2026-09-03 00:05:38.376889
793	2357	559	9	\N	\N	t	f	2026-09-03 00:05:38.376889
794	2364	555	3	\N	\N	t	f	2026-09-03 00:05:38.376889
795	2365	566	1	\N	\N	t	f	2026-09-03 00:05:38.376889
796	2366	555	12	\N	\N	t	f	2026-09-03 00:05:38.376889
797	2367	560	6	\N	\N	t	f	2026-09-03 00:05:38.376889
798	2371	552	8	\N	\N	t	f	2026-09-03 00:05:38.376889
799	2373	551	11	\N	\N	t	f	2026-09-03 00:05:38.376889
800	2374	557	6	\N	\N	t	f	2026-09-03 00:05:38.376889
801	2375	560	9	\N	\N	t	f	2026-09-03 00:05:38.376889
802	2376	570	9	\N	\N	t	f	2026-09-03 00:05:38.376889
803	2378	556	7	\N	\N	t	f	2026-09-03 00:05:38.376889
804	2379	559	5	\N	\N	t	f	2026-09-03 00:05:38.376889
805	2381	563	9	\N	\N	t	f	2026-09-03 00:05:38.376889
806	2386	552	5	\N	\N	t	f	2026-09-03 00:05:38.376889
807	2388	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
808	2389	564	8	\N	\N	t	f	2026-09-03 00:05:38.376889
809	2390	553	3	\N	\N	t	f	2026-09-03 00:05:38.376889
810	2391	555	1	\N	\N	t	f	2026-09-03 00:05:38.376889
811	2392	551	5	\N	\N	t	f	2026-09-03 00:05:38.376889
812	2393	557	1	\N	\N	t	f	2026-09-03 00:05:38.376889
813	2394	569	11	\N	\N	t	f	2026-09-03 00:05:38.376889
814	2396	554	12	\N	\N	t	f	2026-09-03 00:05:38.376889
815	2398	567	6	\N	\N	t	f	2026-09-03 00:05:38.376889
816	2399	552	7	\N	\N	t	f	2026-09-03 00:05:38.376889
817	2400	557	2	\N	\N	t	f	2026-09-03 00:05:38.376889
818	2402	569	4	\N	\N	t	f	2026-09-03 00:05:38.376889
819	2403	568	5	\N	\N	t	f	2026-09-03 00:05:38.376889
820	2413	565	2	\N	\N	t	f	2026-09-03 00:05:38.376889
821	2417	556	5	\N	\N	t	f	2026-09-03 00:05:38.376889
822	2418	553	2	\N	\N	t	f	2026-09-03 00:05:38.376889
823	2420	568	6	\N	\N	t	f	2026-09-03 00:05:38.376889
824	2422	561	9	\N	\N	t	f	2026-09-03 00:05:38.376889
825	2426	561	5	\N	\N	t	f	2026-09-03 00:05:38.376889
826	2427	561	8	\N	\N	t	f	2026-09-03 00:05:38.376889
827	2428	560	5	\N	\N	t	f	2026-09-03 00:05:38.376889
828	2430	562	1	\N	\N	t	f	2026-09-03 00:05:38.376889
829	2431	570	12	\N	\N	t	f	2026-09-03 00:05:38.376889
830	2433	566	1	\N	\N	t	f	2026-09-03 00:05:38.376889
831	2435	566	1	\N	\N	t	f	2026-09-03 00:05:38.376889
832	2438	569	6	\N	\N	t	f	2026-09-03 00:05:38.376889
833	2440	569	7	\N	\N	t	f	2026-09-03 00:05:38.376889
834	2442	567	12	\N	\N	t	f	2026-09-03 00:05:38.376889
835	2445	556	9	\N	\N	t	f	2026-09-03 00:05:38.376889
836	2446	570	11	\N	\N	t	f	2026-09-03 00:05:38.376889
837	2450	563	7	\N	\N	t	f	2026-09-03 00:05:38.376889
838	2452	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
839	2454	561	12	\N	\N	t	f	2026-09-03 00:05:38.376889
840	2455	561	2	\N	\N	t	f	2026-09-03 00:05:38.376889
841	2457	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
842	2459	568	8	\N	\N	t	f	2026-09-03 00:05:38.376889
843	2461	561	7	\N	\N	t	f	2026-09-03 00:05:38.376889
844	2462	552	9	\N	\N	t	f	2026-09-03 00:05:38.376889
845	2464	565	4	\N	\N	t	f	2026-09-03 00:05:38.376889
846	2465	565	8	\N	\N	t	f	2026-09-03 00:05:38.376889
847	2467	557	12	\N	\N	t	f	2026-09-03 00:05:38.376889
848	2471	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
849	2473	554	7	\N	\N	t	f	2026-09-03 00:05:38.376889
850	2478	570	12	\N	\N	t	f	2026-09-03 00:05:38.376889
851	2479	563	1	\N	\N	t	f	2026-09-03 00:05:38.376889
852	2480	565	6	\N	\N	t	f	2026-09-03 00:05:38.376889
853	2483	551	1	\N	\N	t	f	2026-09-03 00:05:38.376889
854	2484	563	1	\N	\N	t	f	2026-09-03 00:05:38.376889
855	2485	554	11	\N	\N	t	f	2026-09-03 00:05:38.376889
856	2488	553	6	\N	\N	t	f	2026-09-03 00:05:38.376889
857	2490	565	5	\N	\N	t	f	2026-09-03 00:05:38.376889
858	2491	568	1	\N	\N	t	f	2026-09-03 00:05:38.376889
859	2492	557	11	\N	\N	t	f	2026-09-03 00:05:38.376889
860	2496	569	4	\N	\N	t	f	2026-09-03 00:05:38.376889
861	2497	568	7	\N	\N	t	f	2026-09-03 00:05:38.376889
862	2498	567	7	\N	\N	t	f	2026-09-03 00:05:38.376889
863	2500	566	9	\N	\N	t	f	2026-09-03 00:05:38.376889
864	2503	559	7	\N	\N	t	f	2026-09-03 00:05:38.376889
865	2506	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
866	2507	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
867	2508	554	3	\N	\N	t	f	2026-09-03 00:05:38.376889
868	2511	553	12	\N	\N	t	f	2026-09-03 00:05:38.376889
869	2513	567	3	\N	\N	t	f	2026-09-03 00:05:38.376889
870	2514	568	10	\N	\N	t	f	2026-09-03 00:05:38.376889
871	2515	565	2	\N	\N	t	f	2026-09-03 00:05:38.376889
872	2520	568	9	\N	\N	t	f	2026-09-03 00:05:38.376889
873	2525	556	8	\N	\N	t	f	2026-09-03 00:05:38.376889
874	2531	560	5	\N	\N	t	f	2026-09-03 00:05:38.376889
875	2532	556	12	\N	\N	t	f	2026-09-03 00:05:38.376889
876	2533	566	4	\N	\N	t	f	2026-09-03 00:05:38.376889
877	2534	567	5	\N	\N	t	f	2026-09-03 00:05:38.376889
878	2535	569	4	\N	\N	t	f	2026-09-03 00:05:38.376889
879	2536	566	10	\N	\N	t	f	2026-09-03 00:05:38.376889
880	2539	560	6	\N	\N	t	f	2026-09-03 00:05:38.376889
881	2541	554	5	\N	\N	t	f	2026-09-03 00:05:38.376889
882	2542	557	1	\N	\N	t	f	2026-09-03 00:05:38.376889
883	2545	554	11	\N	\N	t	f	2026-09-03 00:05:38.376889
884	2546	570	11	\N	\N	t	f	2026-09-03 00:05:38.376889
885	2547	568	11	\N	\N	t	f	2026-09-03 00:05:38.376889
886	2548	554	3	\N	\N	t	f	2026-09-03 00:05:38.376889
887	2549	558	10	\N	\N	t	f	2026-09-03 00:05:38.376889
888	2551	552	10	\N	\N	t	f	2026-09-03 00:05:38.376889
889	2557	561	8	\N	\N	t	f	2026-09-03 00:05:38.376889
890	2558	563	5	\N	\N	t	f	2026-09-03 00:05:38.376889
891	2565	566	1	\N	\N	t	f	2026-09-03 00:05:38.376889
892	2569	552	8	\N	\N	t	f	2026-09-03 00:05:38.376889
893	2570	567	1	\N	\N	t	f	2026-09-03 00:05:38.376889
894	2572	553	11	\N	\N	t	f	2026-09-03 00:05:38.376889
895	2573	568	5	\N	\N	t	f	2026-09-03 00:05:38.376889
896	2576	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
897	2579	552	7	\N	\N	t	f	2026-09-03 00:05:38.376889
898	2584	558	7	\N	\N	t	f	2026-09-03 00:05:38.376889
899	2586	560	7	\N	\N	t	f	2026-09-03 00:05:38.376889
900	2587	557	10	\N	\N	t	f	2026-09-03 00:05:38.376889
901	2591	558	7	\N	\N	t	f	2026-09-03 00:05:38.376889
902	2592	556	11	\N	\N	t	f	2026-09-03 00:05:38.376889
903	2596	567	9	\N	\N	t	f	2026-09-03 00:05:38.376889
904	2597	569	2	\N	\N	t	f	2026-09-03 00:05:38.376889
905	2602	551	7	\N	\N	t	f	2026-09-03 00:05:38.376889
906	2603	567	8	\N	\N	t	f	2026-09-03 00:05:38.376889
907	2605	565	9	\N	\N	t	f	2026-09-03 00:05:38.376889
908	2606	567	3	\N	\N	t	f	2026-09-03 00:05:38.376889
909	2610	559	6	\N	\N	t	f	2026-09-03 00:05:38.376889
910	2611	568	12	\N	\N	t	f	2026-09-03 00:05:38.376889
911	2613	558	4	\N	\N	t	f	2026-09-03 00:05:38.376889
912	2614	565	1	\N	\N	t	f	2026-09-03 00:05:38.376889
913	2615	565	12	\N	\N	t	f	2026-09-03 00:05:38.376889
914	2616	555	3	\N	\N	t	f	2026-09-03 00:05:38.376889
915	2619	569	5	\N	\N	t	f	2026-09-03 00:05:38.376889
916	2624	558	3	\N	\N	t	f	2026-09-03 00:05:38.376889
917	2625	553	7	\N	\N	t	f	2026-09-03 00:05:38.376889
918	2626	561	11	\N	\N	t	f	2026-09-03 00:05:38.376889
919	2629	551	2	\N	\N	t	f	2026-09-03 00:05:38.376889
920	2630	560	5	\N	\N	t	f	2026-09-03 00:05:38.376889
921	2632	566	8	\N	\N	t	f	2026-09-03 00:05:38.376889
922	2635	569	9	\N	\N	t	f	2026-09-03 00:05:38.376889
923	2637	551	11	\N	\N	t	f	2026-09-03 00:05:38.376889
924	2639	561	2	\N	\N	t	f	2026-09-03 00:05:38.376889
925	2642	566	6	\N	\N	t	f	2026-09-03 00:05:38.376889
926	2644	566	11	\N	\N	t	f	2026-09-03 00:05:38.376889
927	2645	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
928	2647	569	7	\N	\N	t	f	2026-09-03 00:05:38.376889
929	2650	566	5	\N	\N	t	f	2026-09-03 00:05:38.376889
930	2655	556	10	\N	\N	t	f	2026-09-03 00:05:38.376889
931	2656	564	5	\N	\N	t	f	2026-09-03 00:05:38.376889
932	2659	554	4	\N	\N	t	f	2026-09-03 00:05:38.376889
933	2662	564	12	\N	\N	t	f	2026-09-03 00:05:38.376889
934	2663	567	9	\N	\N	t	f	2026-09-03 00:05:38.376889
935	2671	570	6	\N	\N	t	f	2026-09-03 00:05:38.376889
936	2672	559	4	\N	\N	t	f	2026-09-03 00:05:38.376889
937	2675	561	2	\N	\N	t	f	2026-09-03 00:05:38.376889
938	2676	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
939	2680	554	6	\N	\N	t	f	2026-09-03 00:05:38.376889
940	2684	569	12	\N	\N	t	f	2026-09-03 00:05:38.376889
941	2685	570	9	\N	\N	t	f	2026-09-03 00:05:38.376889
942	2688	558	4	\N	\N	t	f	2026-09-03 00:05:38.376889
943	2689	560	8	\N	\N	t	f	2026-09-03 00:05:38.376889
944	2691	560	2	\N	\N	t	f	2026-09-03 00:05:38.376889
945	2692	551	6	\N	\N	t	f	2026-09-03 00:05:38.376889
946	2694	569	6	\N	\N	t	f	2026-09-03 00:05:38.376889
947	2695	568	8	\N	\N	t	f	2026-09-03 00:05:38.376889
948	2696	558	6	\N	\N	t	f	2026-09-03 00:05:38.376889
949	2698	560	2	\N	\N	t	f	2026-09-03 00:05:38.376889
950	2701	556	2	\N	\N	t	f	2026-09-03 00:05:38.376889
951	2704	560	12	\N	\N	t	f	2026-09-03 00:05:38.376889
952	2705	570	10	\N	\N	t	f	2026-09-03 00:05:38.376889
953	2706	570	7	\N	\N	t	f	2026-09-03 00:05:38.376889
954	2709	568	2	\N	\N	t	f	2026-09-03 00:05:38.376889
955	2710	558	10	\N	\N	t	f	2026-09-03 00:05:38.376889
956	2711	568	4	\N	\N	t	f	2026-09-03 00:05:38.376889
957	2712	565	10	\N	\N	t	f	2026-09-03 00:05:38.376889
958	2713	567	8	\N	\N	t	f	2026-09-03 00:05:38.376889
959	2714	562	9	\N	\N	t	f	2026-09-03 00:05:38.376889
960	2715	551	11	\N	\N	t	f	2026-09-03 00:05:38.376889
961	2716	558	11	\N	\N	t	f	2026-09-03 00:05:38.376889
962	2719	568	7	\N	\N	t	f	2026-09-03 00:05:38.376889
963	2726	570	4	\N	\N	t	f	2026-09-03 00:05:38.376889
964	2734	562	11	\N	\N	t	f	2026-09-03 00:05:38.376889
965	2738	567	7	\N	\N	t	f	2026-09-03 00:05:38.376889
966	2740	570	8	\N	\N	t	f	2026-09-03 00:05:38.376889
967	2743	563	4	\N	\N	t	f	2026-09-03 00:05:38.376889
968	2744	562	4	\N	\N	t	f	2026-09-03 00:05:38.376889
969	2746	567	4	\N	\N	t	f	2026-09-03 00:05:38.376889
970	2748	556	11	\N	\N	t	f	2026-09-03 00:05:38.376889
971	2751	562	1	\N	\N	t	f	2026-09-03 00:05:38.376889
972	2753	560	10	\N	\N	t	f	2026-09-03 00:05:38.376889
973	2754	566	11	\N	\N	t	f	2026-09-03 00:05:38.376889
974	2755	553	10	\N	\N	t	f	2026-09-03 00:05:38.376889
975	2756	561	3	\N	\N	t	f	2026-09-03 00:05:38.376889
\.


--
-- Data for Name: model_versions; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.model_versions (model_version_id, model_type, version_name, model_path, dataset_version, accuracy, precision_score, recall_score, f1_score, trained_at, deployed_at, is_active) FROM stdin;
1	symptom_tabular	RF_v1_base	s3://models/rf_v1.pkl	\N	0.8500	\N	\N	\N	2026-09-02 21:43:07.537208	\N	t
2	image	CNN_v1_base	s3://models/cnn_v1.pth	\N	0.8800	\N	\N	\N	2026-09-02 21:43:07.537208	\N	t
3	multimodal	Ensemble_v1_base	s3://models/ensemble_v1.pkl	\N	0.9200	\N	\N	\N	2026-09-02 21:43:07.537208	\N	t
\.


--
-- Data for Name: predefined_symptom_map; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.predefined_symptom_map (map_id, symptom_id, disease_id, species_id, symptom_weight, is_pathognomonic) FROM stdin;
1	35	11	1	0.70	f
2	47	11	1	0.60	f
3	62	11	1	0.90	t
4	63	11	1	0.70	f
5	64	11	1	0.50	f
6	65	11	1	0.50	f
7	66	11	1	0.60	f
8	67	11	1	0.60	f
9	68	11	1	0.50	f
10	47	8	1	0.60	f
11	23	4	1	0.70	f
12	24	4	1	0.80	f
13	25	4	1	0.80	f
14	26	4	1	0.90	t
15	12	2	1	0.90	t
16	27	8	2	0.60	f
17	12	2	2	0.90	t
18	27	8	3	0.60	f
19	35	9	4	0.60	f
20	53	9	4	0.60	f
21	54	9	4	0.90	t
22	55	9	4	0.60	f
23	52	8	4	0.80	f
24	12	3	13	0.90	f
25	16	3	13	0.80	f
26	17	3	13	0.85	t
27	12	3	14	0.90	f
28	4	12	\N	0.50	f
29	69	12	\N	0.90	t
30	2	10	\N	0.50	f
31	56	10	\N	0.70	f
32	57	10	\N	0.60	f
33	58	10	\N	0.85	t
34	59	10	\N	0.50	f
35	60	10	\N	0.40	f
36	61	10	\N	0.40	f
37	30	8	\N	0.50	f
38	35	8	\N	0.60	f
39	48	8	\N	0.80	f
40	49	8	\N	0.90	t
41	50	8	\N	0.90	t
42	51	8	\N	0.60	f
43	2	7	\N	0.50	f
44	43	7	\N	0.70	f
45	44	7	\N	0.60	f
46	45	7	\N	0.60	f
47	46	7	\N	0.50	f
48	4	6	\N	0.50	f
49	35	6	\N	0.60	f
50	36	6	\N	0.70	f
51	37	6	\N	0.50	f
52	38	6	\N	0.50	f
53	39	6	\N	0.80	f
54	40	6	\N	0.60	f
55	41	6	\N	0.70	f
56	42	6	\N	0.95	t
57	1	5	\N	0.60	f
58	27	5	\N	0.70	f
59	28	5	\N	0.80	f
60	29	5	\N	0.90	t
61	30	5	\N	0.50	f
62	31	5	\N	0.50	f
63	32	5	\N	0.60	f
64	33	5	\N	0.60	f
65	34	5	\N	0.70	f
66	6	3	\N	0.50	f
67	15	3	\N	0.80	f
68	18	3	\N	0.50	f
69	19	3	\N	0.60	f
70	20	3	\N	0.70	f
71	21	3	\N	0.40	f
72	22	3	\N	0.50	f
73	1	2	\N	0.60	f
74	13	2	\N	0.90	t
75	14	2	\N	0.70	f
76	1	1	\N	0.80	f
77	2	1	\N	0.60	f
78	3	1	\N	0.80	f
79	4	1	\N	0.60	f
80	5	1	\N	0.60	f
81	6	1	\N	0.60	f
82	7	1	\N	0.90	t
83	8	1	\N	0.50	f
84	9	1	\N	0.60	f
85	10	1	\N	0.50	f
86	11	1	\N	0.50	f
\.


--
-- Data for Name: species; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.species (species_id, species_name) FROM stdin;
1	Cattle
2	Sheep
3	Goats
4	Pigs
5	Dogs
6	Cats
7	Horses
8	Buffalo
9	Wild Boars
10	Warthogs
11	Bush Pigs
12	Giant Forest Hogs
13	Chickens
14	Turkeys
15	Ducks
16	Geese
17	Wild Aquatic Birds
18	Humans
19	Donkeys
20	Camels
21	Giraffes
\.


--
-- Data for Name: symptoms; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.symptoms (symptom_id, symptom_name, description) FROM stdin;
1	High fever	\N
2	Loss of appetite	\N
3	Skin discoloration	\N
4	Respiratory distress	\N
5	Vomiting	\N
6	Diarrhea	\N
7	Internal hemorrhages	\N
8	Weight loss	\N
9	Skin ulcers	\N
10	Joint swelling	\N
11	Respiratory issues	\N
12	Sudden death	\N
13	Blood around nose, mouth, and anus	\N
14	Oedema in throat and shoulder	\N
15	Severe respiratory distress	\N
16	Swelling of head, comb, wattles, and legs	\N
17	Cyanosis of comb and wattles	\N
18	Decreased feed/water intake	\N
19	Drop in egg production	\N
20	Nervous signs (tremors, incoordination, torticollis)	\N
21	Mild respiratory signs	\N
22	Reduced egg production	\N
23	High temperature	\N
24	Jaundice-like symptoms	\N
25	Yellowish mucosal membrane	\N
26	Coffee-colour urine	\N
27	Lameness	\N
28	Swelling in neck, shoulder, lumbar, gluteal, sacral regions	\N
29	Dark and crepitant skin	\N
30	Loss of feed intake	\N
31	Colic	\N
32	Lateral recumbency	\N
33	Dyspnoea	\N
34	Death	\N
35	Fever	\N
36	Swelling of face, neck, and eyelids	\N
37	Nasal discharge	\N
38	Salivation	\N
39	Necrotic ulcers on tongue, dental pad, gum, lips	\N
40	Hyperaemia of muzzle	\N
41	Bleeding at muco-cutaneous junction	\N
42	Swollen, cyanotic, purple-blue tongue	\N
43	Fluctuating high fever	\N
44	Swollen lymph glands	\N
45	Chronic emaciation and weakness	\N
46	Gradual loss of production	\N
47	Drop in milk production	\N
48	Drooling of saliva (ropey string)	\N
49	Vesicles on tongue, lips, gums, palate	\N
50	Vesicles in interdigital skin and coronary band	\N
51	Smacking sound due to mouth pain	\N
52	Snout and feet lesions	\N
53	Conjunctivitis	\N
54	Purplish discolouration of snout, ears, abdomen, legs	\N
55	Staggering gait	\N
56	Progressive anaemia	\N
57	Pale mucous membrane	\N
58	Sub-mandibular oedema (bottle jaw)	\N
59	Weakness in movement	\N
60	Isolation from flock	\N
61	Loss in production	\N
62	Skin nodules	\N
63	Edema and swelling of limbs, brisket, genitalia	\N
64	Nasal and ocular discharge	\N
65	Excessive salivation	\N
66	Enlarged lymph nodes	\N
67	Infertility and abortion	\N
68	Reduced weight gain	\N
69	Pock lesions on non-hairy parts	\N
\.


--
-- Data for Name: triage_results; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.triage_results (triage_id, report_id, symptom_model_version_id, image_model_version_id, multimodal_model_version_id, symptom_prediction_id, symptom_confidence, image_prediction_id, image_confidence, final_prediction_id, final_confidence, risk_score, risk_level, processing_method, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.users (user_id, username, role) FROM stdin;
1	farmer_1	Farmer
2	farmer_2	Farmer
3	farmer_3	Farmer
4	farmer_4	Farmer
5	farmer_5	Farmer
6	farmer_6	Farmer
7	farmer_7	Farmer
8	farmer_8	Farmer
9	farmer_9	Farmer
10	farmer_10	Farmer
11	farmer_11	Farmer
12	farmer_12	Farmer
13	farmer_13	Farmer
14	farmer_14	Farmer
15	farmer_15	Farmer
16	farmer_16	Farmer
17	farmer_17	Farmer
18	farmer_18	Farmer
19	farmer_19	Farmer
20	farmer_20	Farmer
21	farmer_21	Farmer
22	farmer_22	Farmer
23	farmer_23	Farmer
24	farmer_24	Farmer
25	farmer_25	Farmer
26	farmer_26	Farmer
27	farmer_27	Farmer
28	farmer_28	Farmer
29	farmer_29	Farmer
30	farmer_30	Farmer
31	farmer_31	Farmer
32	farmer_32	Farmer
33	farmer_33	Farmer
34	farmer_34	Farmer
35	farmer_35	Farmer
36	farmer_36	Farmer
37	farmer_37	Farmer
38	farmer_38	Farmer
39	farmer_39	Farmer
40	farmer_40	Farmer
41	farmer_41	Farmer
42	farmer_42	Farmer
43	farmer_43	Farmer
44	farmer_44	Farmer
45	farmer_45	Farmer
46	farmer_46	Farmer
47	farmer_47	Farmer
48	farmer_48	Farmer
49	farmer_49	Farmer
50	farmer_50	Farmer
51	farmer_51	Farmer
52	farmer_52	Farmer
53	farmer_53	Farmer
54	farmer_54	Farmer
55	farmer_55	Farmer
56	farmer_56	Farmer
57	farmer_57	Farmer
58	farmer_58	Farmer
59	farmer_59	Farmer
60	farmer_60	Farmer
61	farmer_61	Farmer
62	farmer_62	Farmer
63	farmer_63	Farmer
64	farmer_64	Farmer
65	farmer_65	Farmer
66	farmer_66	Farmer
67	farmer_67	Farmer
68	farmer_68	Farmer
69	farmer_69	Farmer
70	farmer_70	Farmer
71	farmer_71	Farmer
72	farmer_72	Farmer
73	farmer_73	Farmer
74	farmer_74	Farmer
75	farmer_75	Farmer
76	farmer_76	Farmer
77	farmer_77	Farmer
78	farmer_78	Farmer
79	farmer_79	Farmer
80	farmer_80	Farmer
81	farmer_81	Farmer
82	farmer_82	Farmer
83	farmer_83	Farmer
84	farmer_84	Farmer
85	farmer_85	Farmer
86	farmer_86	Farmer
87	farmer_87	Farmer
88	farmer_88	Farmer
89	farmer_89	Farmer
90	farmer_90	Farmer
91	farmer_91	Farmer
92	farmer_92	Farmer
93	farmer_93	Farmer
94	farmer_94	Farmer
95	farmer_95	Farmer
96	farmer_96	Farmer
97	farmer_97	Farmer
98	farmer_98	Farmer
99	farmer_99	Farmer
100	farmer_100	Farmer
101	farmer_101	Farmer
102	farmer_102	Farmer
103	farmer_103	Farmer
104	farmer_104	Farmer
105	farmer_105	Farmer
106	farmer_106	Farmer
107	farmer_107	Farmer
108	farmer_108	Farmer
109	farmer_109	Farmer
110	farmer_110	Farmer
111	farmer_111	Farmer
112	farmer_112	Farmer
113	farmer_113	Farmer
114	farmer_114	Farmer
115	farmer_115	Farmer
116	farmer_116	Farmer
117	farmer_117	Farmer
118	farmer_118	Farmer
119	farmer_119	Farmer
120	farmer_120	Farmer
121	farmer_121	Farmer
122	farmer_122	Farmer
123	farmer_123	Farmer
124	farmer_124	Farmer
125	farmer_125	Farmer
126	farmer_126	Farmer
127	farmer_127	Farmer
128	farmer_128	Farmer
129	farmer_129	Farmer
130	farmer_130	Farmer
131	farmer_131	Farmer
132	farmer_132	Farmer
133	farmer_133	Farmer
134	farmer_134	Farmer
135	farmer_135	Farmer
136	farmer_136	Farmer
137	farmer_137	Farmer
138	farmer_138	Farmer
139	farmer_139	Farmer
140	farmer_140	Farmer
141	farmer_141	Farmer
142	farmer_142	Farmer
143	farmer_143	Farmer
144	farmer_144	Farmer
145	farmer_145	Farmer
146	farmer_146	Farmer
147	farmer_147	Farmer
148	farmer_148	Farmer
149	farmer_149	Farmer
150	farmer_150	Farmer
151	farmer_151	Farmer
152	farmer_152	Farmer
153	farmer_153	Farmer
154	farmer_154	Farmer
155	farmer_155	Farmer
156	farmer_156	Farmer
157	farmer_157	Farmer
158	farmer_158	Farmer
159	farmer_159	Farmer
160	farmer_160	Farmer
161	farmer_161	Farmer
162	farmer_162	Farmer
163	farmer_163	Farmer
164	farmer_164	Farmer
165	farmer_165	Farmer
166	farmer_166	Farmer
167	farmer_167	Farmer
168	farmer_168	Farmer
169	farmer_169	Farmer
170	farmer_170	Farmer
171	farmer_171	Farmer
172	farmer_172	Farmer
173	farmer_173	Farmer
174	farmer_174	Farmer
175	farmer_175	Farmer
176	farmer_176	Farmer
177	farmer_177	Farmer
178	farmer_178	Farmer
179	farmer_179	Farmer
180	farmer_180	Farmer
181	farmer_181	Farmer
182	farmer_182	Farmer
183	farmer_183	Farmer
184	farmer_184	Farmer
185	farmer_185	Farmer
186	farmer_186	Farmer
187	farmer_187	Farmer
188	farmer_188	Farmer
189	farmer_189	Farmer
190	farmer_190	Farmer
191	farmer_191	Farmer
192	farmer_192	Farmer
193	farmer_193	Farmer
194	farmer_194	Farmer
195	farmer_195	Farmer
196	farmer_196	Farmer
197	farmer_197	Farmer
198	farmer_198	Farmer
199	farmer_199	Farmer
200	farmer_200	Farmer
201	farmer_201	Farmer
202	farmer_202	Farmer
203	farmer_203	Farmer
204	farmer_204	Farmer
205	farmer_205	Farmer
206	farmer_206	Farmer
207	farmer_207	Farmer
208	farmer_208	Farmer
209	farmer_209	Farmer
210	farmer_210	Farmer
211	farmer_211	Farmer
212	farmer_212	Farmer
213	farmer_213	Farmer
214	farmer_214	Farmer
215	farmer_215	Farmer
216	farmer_216	Farmer
217	farmer_217	Farmer
218	farmer_218	Farmer
219	farmer_219	Farmer
220	farmer_220	Farmer
221	farmer_221	Farmer
222	farmer_222	Farmer
223	farmer_223	Farmer
224	farmer_224	Farmer
225	farmer_225	Farmer
226	farmer_226	Farmer
227	farmer_227	Farmer
228	farmer_228	Farmer
229	farmer_229	Farmer
230	farmer_230	Farmer
231	farmer_231	Farmer
232	farmer_232	Farmer
233	farmer_233	Farmer
234	farmer_234	Farmer
235	farmer_235	Farmer
236	farmer_236	Farmer
237	farmer_237	Farmer
238	farmer_238	Farmer
239	farmer_239	Farmer
240	farmer_240	Farmer
241	farmer_241	Farmer
242	farmer_242	Farmer
243	farmer_243	Farmer
244	farmer_244	Farmer
245	farmer_245	Farmer
246	farmer_246	Farmer
247	farmer_247	Farmer
248	farmer_248	Farmer
249	farmer_249	Farmer
250	farmer_250	Farmer
251	farmer_251	Farmer
252	farmer_252	Farmer
253	farmer_253	Farmer
254	farmer_254	Farmer
255	farmer_255	Farmer
256	farmer_256	Farmer
257	farmer_257	Farmer
258	farmer_258	Farmer
259	farmer_259	Farmer
260	farmer_260	Farmer
261	farmer_261	Farmer
262	farmer_262	Farmer
263	farmer_263	Farmer
264	farmer_264	Farmer
265	farmer_265	Farmer
266	farmer_266	Farmer
267	farmer_267	Farmer
268	farmer_268	Farmer
269	farmer_269	Farmer
270	farmer_270	Farmer
271	farmer_271	Farmer
272	farmer_272	Farmer
273	farmer_273	Farmer
274	farmer_274	Farmer
275	farmer_275	Farmer
276	farmer_276	Farmer
277	farmer_277	Farmer
278	farmer_278	Farmer
279	farmer_279	Farmer
280	farmer_280	Farmer
281	farmer_281	Farmer
282	farmer_282	Farmer
283	farmer_283	Farmer
284	farmer_284	Farmer
285	farmer_285	Farmer
286	farmer_286	Farmer
287	farmer_287	Farmer
288	farmer_288	Farmer
289	farmer_289	Farmer
290	farmer_290	Farmer
291	farmer_291	Farmer
292	farmer_292	Farmer
293	farmer_293	Farmer
294	farmer_294	Farmer
295	farmer_295	Farmer
296	farmer_296	Farmer
297	farmer_297	Farmer
298	farmer_298	Farmer
299	farmer_299	Farmer
300	farmer_300	Farmer
301	farmer_301	Farmer
302	farmer_302	Farmer
303	farmer_303	Farmer
304	farmer_304	Farmer
305	farmer_305	Farmer
306	farmer_306	Farmer
307	farmer_307	Farmer
308	farmer_308	Farmer
309	farmer_309	Farmer
310	farmer_310	Farmer
311	farmer_311	Farmer
312	farmer_312	Farmer
313	farmer_313	Farmer
314	farmer_314	Farmer
315	farmer_315	Farmer
316	farmer_316	Farmer
317	farmer_317	Farmer
318	farmer_318	Farmer
319	farmer_319	Farmer
320	farmer_320	Farmer
321	farmer_321	Farmer
322	farmer_322	Farmer
323	farmer_323	Farmer
324	farmer_324	Farmer
325	farmer_325	Farmer
326	farmer_326	Farmer
327	farmer_327	Farmer
328	farmer_328	Farmer
329	farmer_329	Farmer
330	farmer_330	Farmer
331	farmer_331	Farmer
332	farmer_332	Farmer
333	farmer_333	Farmer
334	farmer_334	Farmer
335	farmer_335	Farmer
336	farmer_336	Farmer
337	farmer_337	Farmer
338	farmer_338	Farmer
339	farmer_339	Farmer
340	farmer_340	Farmer
341	farmer_341	Farmer
342	farmer_342	Farmer
343	farmer_343	Farmer
344	farmer_344	Farmer
345	farmer_345	Farmer
346	farmer_346	Farmer
347	farmer_347	Farmer
348	farmer_348	Farmer
349	farmer_349	Farmer
350	farmer_350	Farmer
351	farmer_351	Farmer
352	farmer_352	Farmer
353	farmer_353	Farmer
354	farmer_354	Farmer
355	farmer_355	Farmer
356	farmer_356	Farmer
357	farmer_357	Farmer
358	farmer_358	Farmer
359	farmer_359	Farmer
360	farmer_360	Farmer
361	farmer_361	Farmer
362	farmer_362	Farmer
363	farmer_363	Farmer
364	farmer_364	Farmer
365	farmer_365	Farmer
366	farmer_366	Farmer
367	farmer_367	Farmer
368	farmer_368	Farmer
369	farmer_369	Farmer
370	farmer_370	Farmer
371	farmer_371	Farmer
372	farmer_372	Farmer
373	farmer_373	Farmer
374	farmer_374	Farmer
375	farmer_375	Farmer
376	farmer_376	Farmer
377	farmer_377	Farmer
378	farmer_378	Farmer
379	farmer_379	Farmer
380	farmer_380	Farmer
381	farmer_381	Farmer
382	farmer_382	Farmer
383	farmer_383	Farmer
384	farmer_384	Farmer
385	farmer_385	Farmer
386	farmer_386	Farmer
387	farmer_387	Farmer
388	farmer_388	Farmer
389	farmer_389	Farmer
390	farmer_390	Farmer
391	farmer_391	Farmer
392	farmer_392	Farmer
393	farmer_393	Farmer
394	farmer_394	Farmer
395	farmer_395	Farmer
396	farmer_396	Farmer
397	farmer_397	Farmer
398	farmer_398	Farmer
399	farmer_399	Farmer
400	farmer_400	Farmer
401	farmer_401	Farmer
402	farmer_402	Farmer
403	farmer_403	Farmer
404	farmer_404	Farmer
405	farmer_405	Farmer
406	farmer_406	Farmer
407	farmer_407	Farmer
408	farmer_408	Farmer
409	farmer_409	Farmer
410	farmer_410	Farmer
411	farmer_411	Farmer
412	farmer_412	Farmer
413	farmer_413	Farmer
414	farmer_414	Farmer
415	farmer_415	Farmer
416	farmer_416	Farmer
417	farmer_417	Farmer
418	farmer_418	Farmer
419	farmer_419	Farmer
420	farmer_420	Farmer
421	farmer_421	Farmer
422	farmer_422	Farmer
423	farmer_423	Farmer
424	farmer_424	Farmer
425	farmer_425	Farmer
426	farmer_426	Farmer
427	farmer_427	Farmer
428	farmer_428	Farmer
429	farmer_429	Farmer
430	farmer_430	Farmer
431	farmer_431	Farmer
432	farmer_432	Farmer
433	farmer_433	Farmer
434	farmer_434	Farmer
435	farmer_435	Farmer
436	farmer_436	Farmer
437	farmer_437	Farmer
438	farmer_438	Farmer
439	farmer_439	Farmer
440	farmer_440	Farmer
441	farmer_441	Farmer
442	farmer_442	Farmer
443	farmer_443	Farmer
444	farmer_444	Farmer
445	farmer_445	Farmer
446	farmer_446	Farmer
447	farmer_447	Farmer
448	farmer_448	Farmer
449	farmer_449	Farmer
450	farmer_450	Farmer
451	farmer_451	Farmer
452	farmer_452	Farmer
453	farmer_453	Farmer
454	farmer_454	Farmer
455	farmer_455	Farmer
456	farmer_456	Farmer
457	farmer_457	Farmer
458	farmer_458	Farmer
459	farmer_459	Farmer
460	farmer_460	Farmer
461	farmer_461	Farmer
462	farmer_462	Farmer
463	farmer_463	Farmer
464	farmer_464	Farmer
465	farmer_465	Farmer
466	farmer_466	Farmer
467	farmer_467	Farmer
468	farmer_468	Farmer
469	farmer_469	Farmer
470	farmer_470	Farmer
471	farmer_471	Farmer
472	farmer_472	Farmer
473	farmer_473	Farmer
474	farmer_474	Farmer
475	farmer_475	Farmer
476	farmer_476	Farmer
477	farmer_477	Farmer
478	farmer_478	Farmer
479	farmer_479	Farmer
480	farmer_480	Farmer
481	farmer_481	Farmer
482	farmer_482	Farmer
483	farmer_483	Farmer
484	farmer_484	Farmer
485	farmer_485	Farmer
486	farmer_486	Farmer
487	farmer_487	Farmer
488	farmer_488	Farmer
489	farmer_489	Farmer
490	farmer_490	Farmer
491	farmer_491	Farmer
492	farmer_492	Farmer
493	farmer_493	Farmer
494	farmer_494	Farmer
495	farmer_495	Farmer
496	farmer_496	Farmer
497	farmer_497	Farmer
498	farmer_498	Farmer
499	farmer_499	Farmer
500	farmer_500	Farmer
501	vet_1	Veterinarian
502	vet_2	Veterinarian
503	vet_3	Veterinarian
504	vet_4	Veterinarian
505	vet_5	Veterinarian
506	vet_6	Veterinarian
507	vet_7	Veterinarian
508	vet_8	Veterinarian
509	vet_9	Veterinarian
510	vet_10	Veterinarian
511	vet_11	Veterinarian
512	vet_12	Veterinarian
513	vet_13	Veterinarian
514	vet_14	Veterinarian
515	vet_15	Veterinarian
516	vet_16	Veterinarian
517	vet_17	Veterinarian
518	vet_18	Veterinarian
519	vet_19	Veterinarian
520	vet_20	Veterinarian
521	vet_21	Veterinarian
522	vet_22	Veterinarian
523	vet_23	Veterinarian
524	vet_24	Veterinarian
525	vet_25	Veterinarian
526	vet_26	Veterinarian
527	vet_27	Veterinarian
528	vet_28	Veterinarian
529	vet_29	Veterinarian
530	vet_30	Veterinarian
531	vet_31	Veterinarian
532	vet_32	Veterinarian
533	vet_33	Veterinarian
534	vet_34	Veterinarian
535	vet_35	Veterinarian
536	vet_36	Veterinarian
537	vet_37	Veterinarian
538	vet_38	Veterinarian
539	vet_39	Veterinarian
540	vet_40	Veterinarian
541	vet_41	Veterinarian
542	vet_42	Veterinarian
543	vet_43	Veterinarian
544	vet_44	Veterinarian
545	vet_45	Veterinarian
546	vet_46	Veterinarian
547	vet_47	Veterinarian
548	vet_48	Veterinarian
549	vet_49	Veterinarian
550	vet_50	Veterinarian
551	labtech_1	Lab Technician
552	labtech_2	Lab Technician
553	labtech_3	Lab Technician
554	labtech_4	Lab Technician
555	labtech_5	Lab Technician
556	labtech_6	Lab Technician
557	labtech_7	Lab Technician
558	labtech_8	Lab Technician
559	labtech_9	Lab Technician
560	labtech_10	Lab Technician
561	labtech_11	Lab Technician
562	labtech_12	Lab Technician
563	labtech_13	Lab Technician
564	labtech_14	Lab Technician
565	labtech_15	Lab Technician
566	labtech_16	Lab Technician
567	labtech_17	Lab Technician
568	labtech_18	Lab Technician
569	labtech_19	Lab Technician
570	labtech_20	Lab Technician
\.


--
-- Data for Name: vet_verifications; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.vet_verifications (verification_id, report_id, vet_id, confirmed_disease_id, is_confirmed, clinical_notes, internal_hemorrhage, used_in_training, verified_at) FROM stdin;
1244	1757	525	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1245	1758	519	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1246	1759	534	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1247	1761	542	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1248	1762	523	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1249	1764	540	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1250	1765	514	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1251	1766	503	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1252	1767	534	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1253	1768	531	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1254	1769	534	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1255	1770	536	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1256	1771	540	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1257	1773	520	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1258	1774	538	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1259	1776	510	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1260	1777	519	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1261	1779	518	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1262	1781	547	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1263	1783	505	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1264	1785	544	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1265	1787	543	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1266	1788	529	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1267	1789	501	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1268	1790	501	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1269	1791	522	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1270	1792	517	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1271	1793	520	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1272	1794	517	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1273	1795	525	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1274	1796	516	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1275	1797	550	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1276	1798	514	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1277	1800	521	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1278	1801	504	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1279	1802	516	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1280	1803	541	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1281	1806	526	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1282	1807	540	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1283	1808	502	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1284	1809	513	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1285	1810	537	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1286	1811	535	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1287	1812	526	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1288	1813	509	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1289	1814	543	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1290	1815	502	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1291	1816	523	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1292	1818	550	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1293	1819	502	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1294	1820	548	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1295	1821	544	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1296	1823	531	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1297	1824	519	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1298	1825	511	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1299	1826	519	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1300	1827	520	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1301	1828	527	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1302	1830	528	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1303	1833	518	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1304	1834	512	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1305	1835	523	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1306	1836	524	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1307	1837	501	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1308	1839	521	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1309	1840	545	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1310	1842	526	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1311	1843	521	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1312	1844	527	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1313	1845	532	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1314	1846	544	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1315	1847	538	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1316	1849	547	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1317	1850	508	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1318	1851	511	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1319	1853	546	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1320	1854	530	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1321	1855	533	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1322	1856	510	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1323	1858	541	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1324	1859	534	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1325	1860	544	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1326	1862	523	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1327	1863	508	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1328	1864	522	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1329	1865	540	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1330	1867	510	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1331	1868	517	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1332	1871	514	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1333	1872	509	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1334	1873	530	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1335	1874	503	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1336	1876	532	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1337	1878	535	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1338	1880	510	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1339	1881	526	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1340	1882	544	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1341	1883	523	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1342	1884	519	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1343	1885	503	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1344	1886	532	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1345	1887	514	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1346	1889	515	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1347	1890	503	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1348	1891	532	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1349	1892	513	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1350	1893	527	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1351	1895	536	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1352	1896	531	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1353	1897	528	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1354	1898	546	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1355	1899	513	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1356	1900	524	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1357	1902	517	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1358	1905	520	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1359	1906	525	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1360	1907	514	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1361	1908	513	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1362	1909	541	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1363	1910	509	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1364	1911	506	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1365	1912	531	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1366	1914	536	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1367	1915	542	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1368	1916	530	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1369	1917	510	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1370	1918	528	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1371	1920	530	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1372	1923	532	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1373	1924	505	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1374	1925	532	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1375	1926	512	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1376	1928	513	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1377	1929	549	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1378	1931	517	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1379	1932	506	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1380	1933	530	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1381	1934	532	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1382	1935	520	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1383	1936	515	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1384	1937	506	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1385	1938	542	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1386	1939	510	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1387	1940	538	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1388	1941	538	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1389	1942	543	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1390	1943	511	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1391	1945	549	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1392	1946	522	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1393	1948	512	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1394	1949	515	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1395	1950	517	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1396	1951	541	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1397	1953	523	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1398	1954	503	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1399	1955	509	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1400	1956	506	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1401	1957	534	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1402	1958	518	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1403	1959	501	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1404	1960	510	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1405	1961	539	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1406	1962	533	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1407	1965	533	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1408	1966	522	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1409	1967	532	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1410	1968	516	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1411	1969	536	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1412	1970	503	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1413	1971	547	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1414	1972	536	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1415	1973	545	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1416	1974	525	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1417	1975	505	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1418	1976	517	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1419	1977	541	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1420	1978	516	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1421	1979	506	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1422	1980	525	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1423	1981	532	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1424	1982	512	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1425	1983	513	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1426	1984	544	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1427	1986	518	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1428	1987	519	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1429	1990	517	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1430	1991	537	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1431	1992	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1432	1994	507	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1433	1995	539	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1434	1996	538	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1435	1997	517	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1436	1998	530	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1437	1999	537	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1438	2000	522	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1439	2001	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1440	2002	519	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1441	2003	534	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1442	2004	514	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1443	2005	548	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1444	2006	532	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1445	2007	514	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1446	2008	550	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1447	2009	541	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1448	2010	530	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1449	2012	524	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1450	2013	536	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1451	2015	507	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1452	2016	532	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1453	2017	502	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1454	2018	507	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1455	2020	509	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1456	2022	511	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1457	2024	548	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1458	2025	519	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1459	2026	537	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1460	2027	522	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1461	2028	550	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1462	2029	541	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1463	2030	545	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1464	2031	512	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1465	2032	546	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1466	2033	501	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1467	2034	530	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1468	2035	507	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1469	2036	521	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1470	2037	512	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1471	2038	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1472	2039	527	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1473	2040	506	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1474	2041	510	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1475	2042	522	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1476	2043	506	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1477	2045	545	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1478	2046	512	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1479	2047	513	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1480	2048	541	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1481	2050	532	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1482	2051	518	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1483	2053	511	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1484	2054	531	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1485	2055	525	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1486	2056	517	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1487	2057	525	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1488	2058	550	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1489	2059	545	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1490	2060	524	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1491	2061	540	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1492	2062	508	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1493	2063	524	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1494	2064	518	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1495	2065	518	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1496	2066	536	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1497	2068	508	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1498	2069	541	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1499	2070	523	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1500	2071	517	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1501	2073	532	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1502	2074	540	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1503	2075	522	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1504	2076	522	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1505	2077	506	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1506	2078	541	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1507	2079	515	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1508	2080	523	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1509	2081	505	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1510	2082	508	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1511	2083	539	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1512	2085	512	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1513	2087	529	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1514	2088	529	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1515	2089	517	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1516	2090	506	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1517	2091	543	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1518	2092	534	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1519	2093	548	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1520	2095	511	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1521	2096	550	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1522	2097	511	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1523	2098	550	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1524	2099	550	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1525	2100	541	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1526	2101	503	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1527	2102	537	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1528	2103	508	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1529	2105	545	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1530	2106	548	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1531	2107	523	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1532	2108	547	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1533	2110	509	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1534	2111	538	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1535	2112	518	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1536	2113	506	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1537	2114	546	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1538	2115	508	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1539	2117	513	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1540	2118	545	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1541	2119	548	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1542	2120	532	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1543	2121	538	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1544	2122	524	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1545	2123	523	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1546	2124	549	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1547	2125	514	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1548	2126	508	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1549	2127	528	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1550	2128	508	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1551	2129	520	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1552	2130	530	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1553	2131	508	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1554	2132	531	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1555	2133	505	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1556	2135	548	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1557	2136	502	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1558	2137	506	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1559	2138	532	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1560	2140	519	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1561	2141	510	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1562	2143	507	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1563	2144	548	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1564	2145	546	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1565	2146	522	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1566	2147	540	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1567	2148	501	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1568	2151	535	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1569	2152	525	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1570	2153	513	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1571	2154	512	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1572	2155	512	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1573	2156	534	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1574	2157	504	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1575	2160	506	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1576	2161	525	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1577	2162	538	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1578	2163	502	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1579	2165	515	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1580	2169	547	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1581	2170	512	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1582	2171	504	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1583	2172	520	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1584	2174	538	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1585	2175	550	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1586	2176	533	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1587	2177	533	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1588	2178	548	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1589	2179	529	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1590	2180	519	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1591	2181	530	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1592	2184	515	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1593	2186	544	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1594	2188	525	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1595	2189	506	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1596	2191	517	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1597	2192	501	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1598	2193	519	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1599	2195	529	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1600	2196	503	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1601	2197	519	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1602	2199	531	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1603	2200	544	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1604	2201	546	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1605	2202	537	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1606	2203	526	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1607	2204	502	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1608	2205	513	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1609	2207	536	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1610	2208	501	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1611	2210	520	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1612	2211	531	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1613	2213	534	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1614	2215	536	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1615	2216	529	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1616	2217	515	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1617	2218	548	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1618	2219	547	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1619	2220	524	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1620	2221	522	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1621	2222	549	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1622	2223	528	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1623	2224	543	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1624	2225	502	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1625	2226	505	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1626	2227	510	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1627	2228	540	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1628	2229	525	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1629	2231	531	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1630	2232	519	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1631	2233	550	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1632	2234	511	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1633	2235	534	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1634	2238	538	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1635	2239	520	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1636	2241	512	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1637	2243	529	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1638	2244	532	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1639	2246	543	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1640	2247	512	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1641	2248	509	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1642	2249	523	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1643	2250	515	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1644	2251	542	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1645	2253	503	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1646	2254	533	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1647	2255	508	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1648	2257	524	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1649	2258	534	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1650	2259	518	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1651	2261	536	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1652	2262	540	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1653	2263	544	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1654	2264	516	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1655	2265	516	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1656	2267	506	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1657	2268	547	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1658	2269	549	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1659	2270	518	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1660	2271	517	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1661	2272	504	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1662	2275	509	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1663	2276	507	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1664	2277	515	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1665	2278	545	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1666	2280	506	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1667	2281	534	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1668	2283	504	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1669	2284	502	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1670	2286	515	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1671	2288	509	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1672	2289	518	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1673	2290	525	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1674	2291	539	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1675	2292	512	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1676	2295	514	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1677	2296	549	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1678	2297	516	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1679	2298	520	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1680	2299	506	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1681	2300	531	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1682	2301	538	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1683	2302	528	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1684	2303	545	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1685	2305	533	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1686	2306	549	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1687	2307	504	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1688	2308	507	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1689	2310	529	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1690	2311	524	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1691	2312	517	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1692	2313	514	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1693	2314	546	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1694	2315	508	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1695	2316	549	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1696	2317	529	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1697	2319	509	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1698	2320	537	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1699	2321	519	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1700	2322	509	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1701	2324	503	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1702	2326	501	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1703	2329	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1704	2330	520	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1705	2331	501	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1706	2332	533	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1707	2333	520	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1708	2334	502	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1709	2335	506	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1710	2336	507	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1711	2337	542	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1712	2338	545	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1713	2339	519	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1714	2340	541	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1715	2341	547	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1716	2343	536	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1717	2344	528	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1718	2345	534	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1719	2347	504	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1720	2348	516	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1721	2349	535	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1722	2350	513	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1723	2352	502	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1724	2353	548	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1725	2354	536	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1726	2355	536	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1727	2356	540	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1728	2357	516	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1729	2359	518	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1730	2360	533	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1731	2361	534	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1732	2362	549	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1733	2363	527	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1734	2364	539	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1735	2365	548	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1736	2366	505	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1737	2368	501	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1738	2369	514	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1739	2370	546	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1740	2371	527	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1741	2372	518	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1742	2373	535	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1743	2376	501	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1744	2377	540	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1745	2378	525	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1746	2383	545	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1747	2384	548	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1748	2385	505	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1749	2386	501	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1750	2387	537	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1751	2388	526	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1752	2390	509	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1753	2391	547	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1754	2392	507	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1755	2394	550	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1756	2395	541	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1757	2396	535	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1758	2397	504	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1759	2398	525	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1760	2401	506	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1761	2402	545	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1762	2404	545	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1763	2405	517	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1764	2406	507	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1765	2407	548	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1766	2408	513	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1767	2409	501	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1768	2411	546	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1769	2412	534	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1770	2413	537	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1771	2414	517	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1772	2415	508	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1773	2416	509	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1774	2417	504	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1775	2421	520	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1776	2422	514	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1777	2423	504	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1778	2424	539	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1779	2425	534	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1780	2426	544	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1781	2427	530	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1782	2430	519	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1783	2431	538	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1784	2432	506	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1785	2434	529	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1786	2435	506	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1787	2437	504	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1788	2438	501	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1789	2439	525	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1790	2440	501	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1791	2441	547	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1792	2442	517	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1793	2443	510	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1794	2444	529	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1795	2445	516	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1796	2446	543	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1797	2448	544	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1798	2450	547	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1799	2451	526	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1800	2452	503	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1801	2453	546	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1802	2454	521	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1803	2455	517	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1804	2456	527	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1805	2457	534	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1806	2458	509	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1807	2459	529	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1808	2460	528	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1809	2461	520	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1810	2462	507	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1811	2463	508	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1812	2464	538	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1813	2465	518	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1814	2466	537	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1815	2467	542	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1816	2468	544	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1817	2469	503	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1818	2470	523	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1819	2472	532	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1820	2473	532	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1821	2474	504	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1822	2475	520	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1823	2476	529	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1824	2478	539	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1825	2480	550	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1826	2481	538	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1827	2482	513	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1828	2483	524	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1829	2484	533	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1830	2485	517	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1831	2487	506	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1832	2488	522	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1833	2490	548	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1834	2491	531	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1835	2492	518	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1836	2493	529	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1837	2494	543	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1838	2496	515	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1839	2497	523	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1840	2498	529	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1841	2499	521	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1842	2501	526	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1843	2502	542	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1844	2503	502	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1845	2504	525	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1846	2506	529	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1847	2507	549	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1848	2508	519	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1849	2509	543	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1850	2510	533	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1851	2511	549	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1852	2513	545	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1853	2514	501	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1854	2516	513	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1855	2518	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1856	2520	517	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1857	2521	501	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1858	2522	511	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1859	2523	537	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1860	2524	501	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1861	2525	536	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1862	2526	541	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1863	2527	518	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1864	2528	524	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1865	2530	530	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1866	2532	545	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1867	2533	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1868	2534	517	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1869	2536	547	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1870	2537	547	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1871	2538	518	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1872	2540	510	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1873	2541	530	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1874	2542	515	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1875	2544	536	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1876	2545	518	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1877	2548	516	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1878	2549	506	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1879	2550	507	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1880	2551	522	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1881	2552	538	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1882	2553	544	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1883	2554	536	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1884	2555	527	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1885	2556	549	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1886	2557	509	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1887	2559	542	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1888	2560	533	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1889	2561	537	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1890	2562	510	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1891	2563	545	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1892	2564	550	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1893	2565	533	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1894	2566	522	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1895	2567	503	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1896	2569	540	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1897	2571	530	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1898	2572	520	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1899	2573	540	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1900	2574	536	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1901	2575	524	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1902	2576	520	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1903	2578	522	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1904	2579	517	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1905	2580	532	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1906	2581	531	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1907	2582	505	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1908	2583	548	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1909	2584	511	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1910	2585	510	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1911	2587	510	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1912	2588	515	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1913	2589	527	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1914	2590	509	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1915	2591	522	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1916	2593	541	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1917	2595	541	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1918	2596	519	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1919	2599	514	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1920	2600	542	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1921	2601	528	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1922	2602	547	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1923	2603	515	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1924	2604	511	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1925	2605	546	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1926	2607	518	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1927	2608	525	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1928	2609	507	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1929	2610	514	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1930	2611	524	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1931	2612	546	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1932	2613	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1933	2614	520	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1934	2615	531	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1935	2616	508	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1936	2617	527	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1937	2618	532	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1938	2619	527	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1939	2620	512	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1940	2623	514	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1941	2624	503	3	t	\N	\N	f	2026-09-03 00:05:38.376889
1942	2625	548	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1943	2626	542	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1944	2627	548	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1945	2628	519	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1946	2629	533	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1947	2630	531	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1948	2631	517	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1949	2632	520	8	t	\N	\N	f	2026-09-03 00:05:38.376889
1950	2633	531	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1951	2634	513	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1952	2635	528	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1953	2636	514	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1954	2637	513	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1955	2638	506	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1956	2639	501	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1957	2641	535	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1958	2642	529	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1959	2643	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1960	2644	528	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1961	2645	504	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1962	2647	534	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1963	2648	534	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1964	2649	532	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1965	2650	516	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1966	2651	515	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1967	2652	522	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1968	2653	522	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1969	2654	527	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1970	2655	505	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1971	2656	519	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1972	2657	549	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1973	2658	547	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1974	2659	532	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1975	2660	519	2	t	\N	\N	f	2026-09-03 00:05:38.376889
1976	2661	527	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1977	2662	517	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1978	2663	535	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1979	2664	512	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1980	2665	533	11	t	\N	\N	f	2026-09-03 00:05:38.376889
1981	2666	524	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1982	2668	521	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1983	2669	537	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1984	2670	512	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1985	2672	539	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1986	2673	542	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1987	2674	546	1	t	\N	\N	f	2026-09-03 00:05:38.376889
1988	2676	505	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1989	2677	536	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1990	2678	513	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1991	2679	520	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1992	2680	507	6	t	\N	\N	f	2026-09-03 00:05:38.376889
1993	2681	547	4	t	\N	\N	f	2026-09-03 00:05:38.376889
1994	2682	534	5	t	\N	\N	f	2026-09-03 00:05:38.376889
1995	2683	537	7	t	\N	\N	f	2026-09-03 00:05:38.376889
1996	2684	525	12	t	\N	\N	f	2026-09-03 00:05:38.376889
1997	2685	539	9	t	\N	\N	f	2026-09-03 00:05:38.376889
1998	2686	502	10	t	\N	\N	f	2026-09-03 00:05:38.376889
1999	2687	543	5	t	\N	\N	f	2026-09-03 00:05:38.376889
2000	2688	516	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2001	2690	522	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2002	2691	501	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2003	2692	511	6	t	\N	\N	f	2026-09-03 00:05:38.376889
2004	2693	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2005	2694	503	6	t	\N	\N	f	2026-09-03 00:05:38.376889
2006	2695	543	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2007	2696	543	6	t	\N	\N	f	2026-09-03 00:05:38.376889
2008	2699	501	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2009	2700	507	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2010	2701	511	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2011	2703	548	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2012	2704	515	12	t	\N	\N	f	2026-09-03 00:05:38.376889
2013	2706	507	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2014	2707	529	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2015	2708	509	10	t	\N	\N	f	2026-09-03 00:05:38.376889
2016	2709	514	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2017	2710	509	10	t	\N	\N	f	2026-09-03 00:05:38.376889
2018	2711	515	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2019	2713	526	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2020	2714	548	9	t	\N	\N	f	2026-09-03 00:05:38.376889
2021	2716	540	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2022	2717	508	6	t	\N	\N	f	2026-09-03 00:05:38.376889
2023	2718	526	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2024	2719	535	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2025	2720	510	9	t	\N	\N	f	2026-09-03 00:05:38.376889
2026	2721	503	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2027	2722	529	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2028	2723	545	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2029	2724	539	9	t	\N	\N	f	2026-09-03 00:05:38.376889
2030	2725	543	5	t	\N	\N	f	2026-09-03 00:05:38.376889
2031	2726	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2032	2731	513	12	t	\N	\N	f	2026-09-03 00:05:38.376889
2033	2733	535	12	t	\N	\N	f	2026-09-03 00:05:38.376889
2034	2734	522	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2035	2735	522	6	t	\N	\N	f	2026-09-03 00:05:38.376889
2036	2736	533	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2037	2738	522	7	t	\N	\N	f	2026-09-03 00:05:38.376889
2038	2739	538	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2039	2740	547	8	t	\N	\N	f	2026-09-03 00:05:38.376889
2040	2741	526	2	t	\N	\N	f	2026-09-03 00:05:38.376889
2041	2742	506	10	t	\N	\N	f	2026-09-03 00:05:38.376889
2042	2743	533	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2043	2744	529	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2044	2745	525	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2045	2746	549	4	t	\N	\N	f	2026-09-03 00:05:38.376889
2046	2747	541	9	t	\N	\N	f	2026-09-03 00:05:38.376889
2047	2749	532	1	t	\N	\N	f	2026-09-03 00:05:38.376889
2048	2750	530	9	t	\N	\N	f	2026-09-03 00:05:38.376889
2049	2751	549	1	t	\N	\N	f	2026-09-03 00:05:38.376889
2050	2753	537	10	t	\N	\N	f	2026-09-03 00:05:38.376889
2051	2754	528	11	t	\N	\N	f	2026-09-03 00:05:38.376889
2052	2755	522	10	t	\N	\N	f	2026-09-03 00:05:38.376889
\.


--
-- Name: diseases_disease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.diseases_disease_id_seq', 12, true);


--
-- Name: field_reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.field_reports_report_id_seq', 2756, true);


--
-- Name: lab_reports_lab_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.lab_reports_lab_report_id_seq', 975, true);


--
-- Name: model_versions_model_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.model_versions_model_version_id_seq', 6, true);


--
-- Name: predefined_symptom_map_map_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.predefined_symptom_map_map_id_seq', 86, true);


--
-- Name: species_species_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.species_species_id_seq', 21, true);


--
-- Name: symptoms_symptom_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.symptoms_symptom_id_seq', 69, true);


--
-- Name: triage_results_triage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.triage_results_triage_id_seq', 600, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1140, true);


--
-- Name: vet_verifications_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.vet_verifications_verification_id_seq', 2052, true);


--
-- Name: diseases diseases_disease_name_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.diseases
    ADD CONSTRAINT diseases_disease_name_key UNIQUE (disease_name);


--
-- Name: diseases diseases_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.diseases
    ADD CONSTRAINT diseases_pkey PRIMARY KEY (disease_id);


--
-- Name: field_reports field_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.field_reports
    ADD CONSTRAINT field_reports_pkey PRIMARY KEY (report_id);


--
-- Name: lab_reports lab_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.lab_reports
    ADD CONSTRAINT lab_reports_pkey PRIMARY KEY (lab_report_id);


--
-- Name: model_versions model_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_versions_pkey PRIMARY KEY (model_version_id);


--
-- Name: model_versions model_versions_version_name_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_versions_version_name_key UNIQUE (version_name);


--
-- Name: predefined_symptom_map predefined_symptom_map_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map
    ADD CONSTRAINT predefined_symptom_map_pkey PRIMARY KEY (map_id);


--
-- Name: predefined_symptom_map predefined_symptom_map_symptom_id_disease_id_species_id_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map
    ADD CONSTRAINT predefined_symptom_map_symptom_id_disease_id_species_id_key UNIQUE (symptom_id, disease_id, species_id);


--
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (species_id);


--
-- Name: species species_species_name_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_species_name_key UNIQUE (species_name);


--
-- Name: symptoms symptoms_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.symptoms
    ADD CONSTRAINT symptoms_pkey PRIMARY KEY (symptom_id);


--
-- Name: symptoms symptoms_symptom_name_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.symptoms
    ADD CONSTRAINT symptoms_symptom_name_key UNIQUE (symptom_name);


--
-- Name: triage_results triage_results_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_pkey PRIMARY KEY (triage_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: vet_verifications vet_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vet_verifications
    ADD CONSTRAINT vet_verifications_pkey PRIMARY KEY (verification_id);


--
-- Name: lab_reports lab_reports_confirmed_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.lab_reports
    ADD CONSTRAINT lab_reports_confirmed_disease_id_fkey FOREIGN KEY (confirmed_disease_id) REFERENCES public.diseases(disease_id);


--
-- Name: lab_reports lab_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.lab_reports
    ADD CONSTRAINT lab_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.field_reports(report_id) ON DELETE CASCADE;


--
-- Name: predefined_symptom_map predefined_symptom_map_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map
    ADD CONSTRAINT predefined_symptom_map_disease_id_fkey FOREIGN KEY (disease_id) REFERENCES public.diseases(disease_id) ON DELETE CASCADE;


--
-- Name: predefined_symptom_map predefined_symptom_map_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map
    ADD CONSTRAINT predefined_symptom_map_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(species_id) ON DELETE CASCADE;


--
-- Name: predefined_symptom_map predefined_symptom_map_symptom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.predefined_symptom_map
    ADD CONSTRAINT predefined_symptom_map_symptom_id_fkey FOREIGN KEY (symptom_id) REFERENCES public.symptoms(symptom_id) ON DELETE CASCADE;


--
-- Name: triage_results triage_results_final_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_final_prediction_id_fkey FOREIGN KEY (final_prediction_id) REFERENCES public.diseases(disease_id);


--
-- Name: triage_results triage_results_image_model_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_image_model_version_id_fkey FOREIGN KEY (image_model_version_id) REFERENCES public.model_versions(model_version_id);


--
-- Name: triage_results triage_results_image_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_image_prediction_id_fkey FOREIGN KEY (image_prediction_id) REFERENCES public.diseases(disease_id);


--
-- Name: triage_results triage_results_multimodal_model_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_multimodal_model_version_id_fkey FOREIGN KEY (multimodal_model_version_id) REFERENCES public.model_versions(model_version_id);


--
-- Name: triage_results triage_results_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.field_reports(report_id) ON DELETE CASCADE;


--
-- Name: triage_results triage_results_symptom_model_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_symptom_model_version_id_fkey FOREIGN KEY (symptom_model_version_id) REFERENCES public.model_versions(model_version_id);


--
-- Name: triage_results triage_results_symptom_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.triage_results
    ADD CONSTRAINT triage_results_symptom_prediction_id_fkey FOREIGN KEY (symptom_prediction_id) REFERENCES public.diseases(disease_id);


--
-- Name: vet_verifications vet_verifications_confirmed_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vet_verifications
    ADD CONSTRAINT vet_verifications_confirmed_disease_id_fkey FOREIGN KEY (confirmed_disease_id) REFERENCES public.diseases(disease_id);


--
-- Name: vet_verifications vet_verifications_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vet_verifications
    ADD CONSTRAINT vet_verifications_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.field_reports(report_id) ON DELETE CASCADE;


--
-- Name: vet_verifications vet_verifications_vet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vet_verifications
    ADD CONSTRAINT vet_verifications_vet_id_fkey FOREIGN KEY (vet_id) REFERENCES public.users(user_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: parag
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict sDS4yplrBh1pvqq63TtewQnZVBkJKK3XPN4tUcIuQY0kGiwzeccwNV7cTQKb4d1

