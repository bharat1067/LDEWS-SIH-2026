--
-- PostgreSQL database dump
--

\restrict shp8sXgBWm74caN3JaUlIu8FKahe7KwhI6AJFZuoAjuWVlbqnElcdZi84Nieote

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
-- Name: vaccination_records; Type: TABLE; Schema: public; Owner: parag
--

CREATE TABLE public.vaccination_records (
    vaccination_id integer NOT NULL,
    farmer_id integer,
    animal_tag_id character varying(50) NOT NULL,
    animal_species character varying(50) NOT NULL,
    disease_protected_id integer,
    vaccine_name character varying(100) NOT NULL,
    vaccinated_on date NOT NULL,
    next_due_date date,
    administered_by character varying(100),
    is_current boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vaccination_records OWNER TO parag;

--
-- Name: vaccination_records_vaccination_id_seq; Type: SEQUENCE; Schema: public; Owner: parag
--

CREATE SEQUENCE public.vaccination_records_vaccination_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vaccination_records_vaccination_id_seq OWNER TO parag;

--
-- Name: vaccination_records_vaccination_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parag
--

ALTER SEQUENCE public.vaccination_records_vaccination_id_seq OWNED BY public.vaccination_records.vaccination_id;


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
-- Name: vaccination_records vaccination_id; Type: DEFAULT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vaccination_records ALTER COLUMN vaccination_id SET DEFAULT nextval('public.vaccination_records_vaccination_id_seq'::regclass);


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
1	\N	Cattle	\N	{35,62,63,66}	26.898606	75.918270	2026-04-14 19:26:39.120021
2	\N	Sheep	\N	{4,8,14,57,69}	18.381392	73.499124	2026-01-08 19:26:39.121004
3	\N	Pigs	\N	{26,35,53,54,55,58}	20.645287	81.428251	2026-08-28 19:26:39.121362
4	\N	Geese	\N	{6,12,15,17,40}	19.865754	87.315409	2025-09-24 19:26:39.121553
5	\N	Cattle	\N	{1,12,13,16}	22.307753	77.503292	2025-12-07 19:26:39.121694
6	\N	Bush Pigs	\N	{1,2,3,6,7,21,54}	18.945602	76.690853	2024-11-29 19:26:39.121832
7	\N	Goats	\N	{2,10,26,56,57,58}	18.549893	75.646372	2025-11-11 19:26:39.121972
8	\N	Sheep	\N	{1,12,13}	22.561515	79.254565	2025-08-26 19:26:39.122147
9	\N	Ducks	\N	{6,12,15,17,31}	26.042102	83.229125	2024-10-04 19:26:39.122336
10	\N	Cattle	\N	{22,32,35,62,63,66}	19.960830	78.071287	2024-11-17 19:26:39.122476
11	\N	Sheep	\N	{4,8,10,44,69}	20.748577	72.513604	2025-10-15 19:26:39.122621
12	\N	Donkeys	\N	{2,43,44,45}	20.531794	87.086555	2025-10-16 19:26:39.122777
13	\N	Buffalo	\N	{23,24,25,26,63}	19.714459	74.234085	2025-02-06 19:26:39.122939
14	\N	Pigs	\N	{35,53,54,55,56,59}	22.343957	87.957212	2026-04-15 19:26:39.123085
15	\N	Pigs	\N	{35,53,54,55}	27.069386	85.777647	2026-03-31 19:26:39.123248
16	\N	Cattle	\N	{9,35,56,62,63,66}	22.617208	81.534215	2025-05-12 19:26:39.123399
17	\N	Pigs	\N	{2,15,35,53,54,55}	26.180524	80.591525	2025-12-04 19:26:39.123555
18	\N	Buffalo	\N	{35,62,63,66}	21.522002	74.530524	2026-08-31 19:26:39.123703
19	\N	Goats	\N	{4,8,25,67,69}	28.951534	85.928297	2025-11-02 19:26:39.123838
20	\N	Cattle	\N	{35,62,63,66}	22.486966	74.584785	2025-03-09 19:26:39.123988
21	\N	Warthogs	\N	{1,2,3,6,7,8}	19.342413	77.807692	2025-10-24 19:26:39.124399
22	\N	Cattle	\N	{23,24,25,26}	28.536115	87.151191	2026-06-08 19:26:39.124754
23	\N	Goats	\N	{4,8,69}	29.735814	80.523299	2026-04-28 19:26:39.124931
24	\N	Geese	\N	{6,12,15,17,26,38}	24.332085	81.705503	2026-01-30 19:26:39.12509
25	\N	Pigs	\N	{35,41,53,54,55,56}	29.941792	82.398049	2025-06-12 19:26:39.125328
26	\N	Pigs	\N	{35,53,54,55}	20.974867	73.024414	2026-08-13 19:26:39.125503
27	\N	Sheep	\N	{1,2,30,56,57,58}	18.851917	82.097647	2026-01-12 19:26:39.125677
28	\N	Cattle	\N	{1,11,12,13}	24.169873	76.455636	2025-04-24 19:26:39.125839
29	\N	Cattle	\N	{23,24,25,26,36,65}	27.415433	84.919952	2026-02-21 19:26:39.126015
30	\N	Cattle	\N	{1,12,13,49,59}	23.082943	79.472395	2026-07-10 19:26:39.126184
31	\N	Cattle	\N	{35,62,63,66}	22.831455	77.428842	2026-05-15 19:26:39.126352
32	\N	Cattle	\N	{23,24,25,26}	24.435429	74.242917	2026-02-28 19:26:39.126497
33	\N	Sheep	\N	{1,27,29,33,34}	28.493831	73.206158	2025-02-17 19:26:39.126642
34	\N	Cattle	\N	{1,3,12,13,15}	29.116404	85.579132	2026-03-17 19:26:39.126793
35	\N	Buffalo	\N	{2,29,43,44,45}	28.375805	86.439086	2026-03-19 19:26:39.126944
36	\N	Cattle	\N	{2,35,43,44,45}	29.118217	84.562070	2025-11-15 19:26:39.127068
37	\N	Buffalo	\N	{2,43,44,45}	20.278774	75.483214	2026-07-06 19:26:39.127187
38	\N	Cattle	\N	{2,9,42,56,57,58}	18.601708	79.628616	2025-03-09 19:26:39.127303
39	\N	Chickens	\N	{6,12,13,15,17,28}	18.822256	73.087374	2026-01-06 19:26:39.127405
40	\N	Cattle	\N	{2,7,33,43,44,45}	25.432578	78.707599	2025-01-14 19:26:39.127501
41	\N	Goats	\N	{2,28,56,57,58}	26.036712	77.026942	2025-12-06 19:26:39.127582
42	\N	Horses	\N	{2,40,43,44,45,63}	21.794126	84.029832	2026-06-21 19:26:39.127664
43	\N	Bush Pigs	\N	{1,2,3,6,7,15,18}	24.451613	80.094155	2026-04-21 19:26:39.127747
44	\N	Sheep	\N	{35,37,38,42}	22.434325	74.523949	2025-02-24 19:26:39.127828
45	\N	Goats	\N	{2,4,8,41,69}	29.181072	73.657384	2026-04-19 19:26:39.127906
46	\N	Cattle	\N	{1,27,29,33,34}	26.909000	74.487167	2025-11-19 19:26:39.127989
47	\N	Sheep	\N	{2,28,45,56,57,58}	26.249966	85.646605	2025-04-04 19:26:39.128067
48	\N	Goats	\N	{35,48,49,50}	19.107582	78.777212	2025-11-24 19:26:39.128164
49	\N	Pigs	\N	{1,2,3,6,7,22}	25.645361	76.191284	2025-06-08 19:26:39.128251
50	\N	Pigs	\N	{2,15,35,53,54,55}	18.902926	86.129702	2026-04-04 19:26:39.128332
51	\N	Pigs	\N	{19,35,53,54,55}	23.157441	72.669262	2025-08-26 19:26:39.128411
52	\N	Warthogs	\N	{1,2,3,6,7}	26.184800	82.670935	2025-09-06 19:26:39.128497
53	\N	Pigs	\N	{20,31,35,53,54,55}	28.375268	87.619297	2026-03-06 19:26:39.128577
54	\N	Cattle	\N	{2,43,44,45}	26.838774	77.314967	2025-07-09 19:26:39.12866
55	\N	Cattle	\N	{21,35,62,63,66}	27.448494	73.729530	2026-07-26 19:26:39.128736
56	\N	Sheep	\N	{35,48,49,50}	27.799039	79.364852	2025-10-26 19:26:39.128812
57	\N	Cattle	\N	{23,24,25,26}	25.920398	78.375456	2025-11-22 19:26:39.128887
58	\N	Horses	\N	{1,12,13,69}	22.796141	87.698395	2025-03-03 19:26:39.128964
59	\N	Sheep	\N	{35,37,38,42}	28.524461	76.179443	2025-01-17 19:26:39.12904
60	\N	Cattle	\N	{1,27,29,33,34}	25.158855	77.530994	2025-10-17 19:26:39.129118
61	\N	Cattle	\N	{2,26,43,44,45}	21.056670	83.340565	2026-09-02 19:26:39.129217
62	\N	Pigs	\N	{35,53,54,55,60}	18.839686	82.627803	2025-09-30 19:26:39.129299
63	\N	Goats	\N	{2,17,40,56,57,58}	24.085470	82.670286	2025-10-04 19:26:39.129387
64	\N	Donkeys	\N	{2,18,26,43,44,45}	23.045356	87.045819	2024-10-10 19:26:39.12947
65	\N	Sheep	\N	{4,8,41,54,69}	24.575247	72.006495	2025-11-14 19:26:39.129548
66	\N	Buffalo	\N	{23,24,25,26,46,64}	23.301432	82.810036	2025-03-29 19:26:39.129626
67	\N	Sheep	\N	{11,35,38,48,49,50}	24.185424	82.127054	2025-09-25 19:26:39.129709
68	\N	Sheep	\N	{1,12,13,32,43}	27.678755	74.357663	2026-07-18 19:26:39.129804
69	\N	Buffalo	\N	{10,23,24,25,26,63}	22.973292	82.076246	2026-02-16 19:26:39.129881
70	\N	Goats	\N	{4,8,54,69}	20.927813	82.496928	2026-08-29 19:26:39.129959
71	\N	Buffalo	\N	{1,12,13}	20.110640	87.327457	2025-03-22 19:26:39.130034
72	\N	Cattle	\N	{16,32,35,48,49,50}	23.477542	84.822666	2024-10-20 19:26:39.130108
73	\N	Pigs	\N	{35,53,54,55,69}	23.120889	86.509676	2025-06-04 19:26:39.130216
74	\N	Geese	\N	{6,12,15,17,38}	27.021321	85.437806	2025-11-24 19:26:39.130331
75	\N	Pigs	\N	{31,35,37,53,54,55}	23.278471	83.416718	2026-01-06 19:26:39.130476
76	\N	Sheep	\N	{1,12,27,29,33,34}	19.660489	75.700184	2024-09-23 19:26:39.130908
77	\N	Turkeys	\N	{6,12,15,17}	22.978415	77.294102	2025-05-14 19:26:39.131141
78	\N	Cattle	\N	{2,43,44,45}	27.994694	78.231629	2025-01-13 19:26:39.131329
79	\N	Sheep	\N	{4,8,51,64,69}	18.070753	77.628141	2025-07-31 19:26:39.13148
80	\N	Horses	\N	{2,30,43,44,45}	21.275224	79.770272	2025-08-01 19:26:39.13162
81	\N	Buffalo	\N	{22,35,37,38,42,64}	29.034499	87.691552	2025-03-06 19:26:39.131751
82	\N	Bush Pigs	\N	{1,2,3,6,7,9,16}	25.712996	74.171192	2025-05-19 19:26:39.131886
83	\N	Chickens	\N	{6,12,15,17,53}	21.928232	79.275189	2025-09-23 19:26:39.13207
84	\N	Donkeys	\N	{2,34,43,44,45}	28.018931	79.524909	2025-02-28 19:26:39.132238
85	\N	Warthogs	\N	{1,2,3,6,7}	25.801729	84.499729	2024-11-05 19:26:39.132391
86	\N	Pigs	\N	{1,2,3,6,7}	20.392328	72.326080	2026-03-31 19:26:39.132533
87	\N	Cattle	\N	{15,23,24,25,26}	24.767635	75.487433	2024-09-17 19:26:39.13266
88	\N	Sheep	\N	{1,27,29,33,34}	25.270712	87.419756	2026-05-09 19:26:39.132795
89	\N	Ducks	\N	{6,12,15,17}	24.944217	86.862195	2025-01-22 19:26:39.132919
90	\N	Buffalo	\N	{26,35,62,63,66}	18.911958	83.049831	2024-11-30 19:26:39.133041
91	\N	Cattle	\N	{16,23,24,25,26,43}	27.554727	81.054921	2026-07-23 19:26:39.133186
92	\N	Buffalo	\N	{9,35,37,38,42,52}	24.071529	77.459699	2025-06-30 19:26:39.133333
93	\N	Cattle	\N	{35,48,49,50,51}	25.627021	85.259317	2024-09-09 19:26:39.133461
94	\N	Geese	\N	{6,12,15,17}	26.805544	87.447580	2025-12-01 19:26:39.133593
95	\N	Buffalo	\N	{2,56,57,58,60}	27.908815	81.479594	2025-10-08 19:26:39.133716
96	\N	Cattle	\N	{23,24,25,26,62}	20.926361	79.435335	2024-12-18 19:26:39.13384
97	\N	Buffalo	\N	{4,35,62,63,66}	23.931678	77.200227	2025-04-22 19:26:39.133962
98	\N	Buffalo	\N	{23,24,25,26,48}	21.355902	81.538480	2025-11-25 19:26:39.134087
99	\N	Pigs	\N	{11,25,35,53,54,55}	20.896273	78.502850	2025-02-12 19:26:39.134226
100	\N	Buffalo	\N	{23,24,25,26,62,67}	27.515194	73.488854	2026-01-20 19:26:39.134369
101	\N	Horses	\N	{2,43,44,45,52}	23.679126	80.494751	2025-06-25 19:26:39.134496
102	\N	Goats	\N	{4,8,61,69}	21.250997	76.022459	2026-05-03 19:26:39.134621
103	\N	Sheep	\N	{4,8,18,69}	26.914573	87.214041	2024-09-27 19:26:39.134777
104	\N	Turkeys	\N	{6,12,15,17}	26.863256	76.423994	2025-01-08 19:26:39.134951
105	\N	Pigs	\N	{35,53,54,55}	27.991540	76.739943	2025-08-30 19:26:39.135093
106	\N	Ducks	\N	{6,12,15,17}	26.496222	74.025327	2026-07-19 19:26:39.135293
107	\N	Warthogs	\N	{1,2,3,6,7,22,68}	19.231052	72.196246	2025-11-16 19:26:39.135457
108	\N	Pigs	\N	{35,45,48,49,50}	20.212364	72.822027	2025-05-02 19:26:39.135653
109	\N	Cattle	\N	{1,12,13,66}	18.888986	82.071131	2026-07-11 19:26:39.135807
110	\N	Turkeys	\N	{6,12,13,15,17,43}	29.927017	73.895225	2025-07-04 19:26:39.135935
111	\N	Sheep	\N	{2,50,56,57,58,62}	28.902053	76.757650	2025-01-09 19:26:39.136072
112	\N	Donkeys	\N	{2,9,14,43,44,45}	29.371082	75.324606	2026-01-30 19:26:39.136243
113	\N	Buffalo	\N	{1,27,29,33,34}	19.884685	74.781017	2026-06-19 19:26:39.136374
114	\N	Chickens	\N	{6,12,15,17,62}	26.272454	79.518600	2026-08-01 19:26:39.136498
115	\N	Buffalo	\N	{23,24,25,26,41,63}	18.854157	75.734781	2025-12-07 19:26:39.136633
116	\N	Cattle	\N	{15,35,62,63,66}	24.534749	82.362156	2025-12-05 19:26:39.136761
117	\N	Chickens	\N	{6,12,15,17}	19.991073	76.921789	2025-01-29 19:26:39.136886
118	\N	Sheep	\N	{1,27,29,33,34}	23.624376	76.865459	2025-07-18 19:26:39.13701
119	\N	Buffalo	\N	{1,27,29,33,34,62,69}	18.965302	72.637773	2025-06-18 19:26:39.137142
120	\N	Goats	\N	{4,5,8,35,69}	19.095923	87.390578	2025-01-22 19:26:39.137281
121	\N	Cattle	\N	{2,7,36,56,57,58}	27.157308	74.803052	2025-03-21 19:26:39.137411
122	\N	Buffalo	\N	{24,35,62,63,66}	29.963346	78.974160	2025-04-18 19:26:39.137536
123	\N	Buffalo	\N	{1,12,13,56}	21.999701	82.722136	2026-03-23 19:26:39.137665
124	\N	Buffalo	\N	{35,37,38,40,42,68}	25.951002	78.407236	2025-02-17 19:26:39.137798
125	\N	Bush Pigs	\N	{1,2,3,6,7}	21.774206	77.172381	2025-07-17 19:26:39.137936
126	\N	Pigs	\N	{35,53,54,55,57,64}	18.650449	80.295030	2024-12-05 19:26:39.138063
127	\N	Pigs	\N	{35,48,49,50}	20.442699	80.787514	2025-11-13 19:26:39.138202
128	\N	Pigs	\N	{35,48,49,50}	18.346433	82.080356	2026-01-01 19:26:39.138356
129	\N	Sheep	\N	{2,4,8,69}	24.627017	73.491347	2026-05-10 19:26:39.138503
130	\N	Cattle	\N	{20,35,48,49,50,68}	29.191837	76.669785	2024-09-11 19:26:39.138636
131	\N	Sheep	\N	{1,27,29,33,34,66}	20.924771	80.820241	2025-08-07 19:26:39.138786
132	\N	Cattle	\N	{23,24,25,26}	21.314969	84.640099	2025-07-06 19:26:39.138936
133	\N	Goats	\N	{35,37,38,42}	21.394068	76.776894	2025-01-10 19:26:39.139082
134	\N	Buffalo	\N	{2,56,57,58}	23.358569	79.749462	2025-09-28 19:26:39.139236
135	\N	Pigs	\N	{35,43,53,54,55}	28.435220	87.692394	2026-01-02 19:26:39.139379
136	\N	Buffalo	\N	{2,56,57,58}	28.272156	78.572402	2025-10-13 19:26:39.13955
137	\N	Goats	\N	{4,8,51,52,69}	29.860968	84.678299	2024-11-05 19:26:39.1397
138	\N	Geese	\N	{6,12,15,17}	19.514955	87.445657	2025-09-29 19:26:39.139836
139	\N	Buffalo	\N	{1,12,13}	24.311413	79.310849	2026-04-09 19:26:39.139968
140	\N	Horses	\N	{2,43,44,45}	23.633887	87.507258	2025-09-22 19:26:39.140099
141	\N	Buffalo	\N	{2,12,44,56,57,58}	28.228096	85.749475	2025-08-10 19:26:39.140285
142	\N	Buffalo	\N	{5,9,35,37,38,42}	20.817243	82.950393	2025-11-13 19:26:39.140495
143	\N	Cattle	\N	{13,23,24,25,26}	27.124436	83.262253	2026-05-24 19:26:39.140671
144	\N	Sheep	\N	{4,35,40,48,49,50}	18.551892	84.738295	2025-11-07 19:26:39.141016
145	\N	Goats	\N	{19,35,37,38,42}	20.930369	78.592828	2024-10-05 19:26:39.14142
146	\N	Turkeys	\N	{6,12,15,17}	18.947620	85.933434	2024-12-08 19:26:39.14164
147	\N	Cattle	\N	{19,35,62,63,66}	20.786261	82.206474	2025-05-21 19:26:39.141841
148	\N	Buffalo	\N	{1,27,29,33,34}	28.786902	79.444052	2025-11-13 19:26:39.142161
149	\N	Cattle	\N	{35,62,63,66}	23.300757	77.529050	2025-01-10 19:26:39.142409
150	\N	Buffalo	\N	{1,27,29,33,34,38}	23.482030	76.833947	2025-08-06 19:26:39.142655
151	\N	Cattle	\N	{35,48,49,50}	22.576372	77.743347	2025-11-05 19:26:39.142849
152	\N	Goats	\N	{4,8,69}	29.735334	82.531677	2025-11-26 19:26:39.14306
153	\N	Pigs	\N	{1,2,3,6,7,42,69}	27.308892	75.681894	2025-09-08 19:26:39.143226
154	\N	Cattle	\N	{18,23,24,25,26,37}	25.538977	86.454459	2024-11-11 19:26:39.143393
155	\N	Warthogs	\N	{1,2,3,6,7,10}	24.954886	83.717756	2026-06-03 19:26:39.14353
156	\N	Sheep	\N	{1,24,27,29,33,34,59}	20.409538	84.584205	2025-08-25 19:26:39.143662
157	\N	Pigs	\N	{35,53,54,55}	21.083641	85.195037	2025-04-28 19:26:39.143807
158	\N	Buffalo	\N	{1,16,27,29,33,34}	23.619977	73.204790	2026-01-15 19:26:39.143936
159	\N	Buffalo	\N	{12,35,48,62,63,66}	27.488184	72.222698	2025-03-03 19:26:39.144044
160	\N	Buffalo	\N	{1,12,13,37}	25.014721	85.158677	2025-08-19 19:26:39.14415
161	\N	Sheep	\N	{1,5,12,13}	25.434562	87.090706	2025-10-03 19:26:39.144247
162	\N	Sheep	\N	{2,10,56,57,58,64}	28.912652	76.835043	2025-07-12 19:26:39.144339
163	\N	Sheep	\N	{1,12,13}	29.355138	76.869833	2025-04-17 19:26:39.144426
164	\N	Cattle	\N	{1,12,13}	28.647112	74.170625	2025-05-27 19:26:39.144525
165	\N	Buffalo	\N	{20,35,37,38,42,58}	25.859063	85.339089	2024-12-12 19:26:39.144635
166	\N	Donkeys	\N	{2,43,44,45}	26.283368	75.476315	2025-06-05 19:26:39.144759
167	\N	Buffalo	\N	{23,24,25,26}	29.771133	77.877359	2024-11-12 19:26:39.144888
168	\N	Sheep	\N	{35,37,38,39,42}	20.277703	73.954556	2025-05-26 19:26:39.144987
169	\N	Sheep	\N	{1,4,8,12,13}	27.441535	75.897102	2026-04-28 19:26:39.14507
170	\N	Sheep	\N	{2,56,57,58}	27.957814	80.867325	2025-01-11 19:26:39.145157
171	\N	Cattle	\N	{19,23,24,25,26}	27.463725	81.535706	2025-11-24 19:26:39.145242
172	\N	Turkeys	\N	{6,12,15,17,27,37}	19.319116	85.863166	2026-04-22 19:26:39.145334
173	\N	Warthogs	\N	{1,2,3,6,7}	25.066235	72.252497	2025-12-06 19:26:39.145463
174	\N	Wild Boars	\N	{1,2,3,6,7,20,59}	26.947983	79.619935	2025-08-29 19:26:39.145597
175	\N	Pigs	\N	{35,53,54,55,69}	20.658597	81.841709	2024-10-29 19:26:39.145706
176	\N	Pigs	\N	{4,35,53,54,55}	18.729905	79.663711	2025-07-19 19:26:39.145787
177	\N	Cattle	\N	{2,43,44,45,61}	18.881889	73.292648	2024-12-20 19:26:39.145866
178	\N	Chickens	\N	{6,12,15,17}	21.300192	82.129228	2025-02-19 19:26:39.145944
179	\N	Goats	\N	{4,8,40,69}	23.444585	81.686829	2026-05-25 19:26:39.14602
180	\N	Sheep	\N	{4,8,30,58,69}	23.418659	75.655897	2025-09-21 19:26:39.146103
181	\N	Pigs	\N	{13,35,48,49,50}	21.750580	77.000377	2025-12-16 19:26:39.146213
182	\N	Cattle	\N	{9,35,37,38,42,65}	19.094697	73.365830	2025-06-18 19:26:39.146304
183	\N	Horses	\N	{1,12,13}	24.676449	81.383441	2025-02-05 19:26:39.146383
184	\N	Pigs	\N	{16,35,53,54,55,57}	22.243177	82.645448	2025-06-27 19:26:39.146471
185	\N	Sheep	\N	{4,8,42,69}	22.219754	81.246696	2026-01-29 19:26:39.14655
186	\N	Geese	\N	{6,12,15,17}	28.167298	77.601824	2025-02-11 19:26:39.146626
187	\N	Sheep	\N	{29,35,37,38,42}	27.686656	85.522483	2024-12-06 19:26:39.14671
188	\N	Cattle	\N	{2,5,36,56,57,58}	20.164993	83.243180	2025-10-22 19:26:39.146798
189	\N	Goats	\N	{35,37,38,42}	20.176867	74.292024	2024-10-30 19:26:39.146877
190	\N	Cattle	\N	{2,43,44,45}	26.891629	87.548965	2026-06-02 19:26:39.146987
191	\N	Sheep	\N	{4,8,56,69}	23.443749	74.518548	2025-10-19 19:26:39.14714
192	\N	Goats	\N	{4,8,9,13,69}	19.866959	84.070974	2026-07-15 19:26:39.147312
193	\N	Cattle	\N	{35,58,62,63,66}	25.943264	79.770587	2025-06-08 19:26:39.147458
194	\N	Donkeys	\N	{2,43,44,45}	27.059318	73.821080	2025-06-20 19:26:39.147597
195	\N	Horses	\N	{1,12,13,43,66}	18.545008	78.324214	2024-12-29 19:26:39.147758
196	\N	Pigs	\N	{1,2,3,6,7}	21.617032	75.379744	2026-04-16 19:26:39.147921
197	\N	Sheep	\N	{1,17,27,29,33,34}	18.092759	83.952226	2026-03-08 19:26:39.148073
198	\N	Geese	\N	{6,12,15,17,34,69}	24.704683	82.688771	2025-09-06 19:26:39.148225
199	\N	Buffalo	\N	{1,7,12,13,59}	18.224898	86.738599	2025-10-18 19:26:39.14836
200	\N	Buffalo	\N	{2,53,55,56,57,58}	21.474182	78.480517	2025-10-06 19:26:39.148512
201	\N	Geese	\N	{6,12,14,15,17,51}	23.240541	73.693810	2025-06-14 19:26:39.148658
202	\N	Buffalo	\N	{2,12,52,56,57,58}	28.446293	83.932877	2026-01-20 19:26:39.148808
203	\N	Cattle	\N	{35,37,38,42}	24.125799	73.824426	2025-03-30 19:26:39.148949
204	\N	Buffalo	\N	{19,23,24,25,26}	20.835226	74.343107	2026-02-13 19:26:39.149088
205	\N	Turkeys	\N	{6,11,12,15,17,27}	29.415506	82.047180	2025-05-16 19:26:39.149257
206	\N	Buffalo	\N	{2,42,43,56,57,58}	19.811489	73.092580	2025-06-08 19:26:39.149391
207	\N	Buffalo	\N	{8,35,62,63,66}	22.223307	73.187050	2025-05-19 19:26:39.149528
208	\N	Cattle	\N	{35,48,49,50}	22.424851	76.593233	2024-11-12 19:26:39.149653
209	\N	Buffalo	\N	{1,7,12,13}	23.396804	84.957055	2024-11-05 19:26:39.149777
210	\N	Buffalo	\N	{23,24,25,26,65,69}	19.810333	72.989979	2026-05-21 19:26:39.149899
211	\N	Sheep	\N	{6,23,35,37,38,42}	20.972925	79.004132	2025-06-11 19:26:39.150025
212	\N	Pigs	\N	{35,49,53,54,55}	29.015241	78.198665	2025-09-22 19:26:39.150184
213	\N	Cattle	\N	{9,35,44,62,63,66}	21.956289	80.927411	2025-08-04 19:26:39.150314
214	\N	Sheep	\N	{1,21,27,29,33,34,48}	18.978024	82.617794	2025-09-10 19:26:39.15044
215	\N	Buffalo	\N	{1,18,27,29,33,34,56}	25.140495	87.008035	2025-10-21 19:26:39.150565
216	\N	Pigs	\N	{17,35,44,53,54,55}	26.041397	85.263344	2024-10-02 19:26:39.150692
217	\N	Pigs	\N	{35,48,53,54,55,59}	18.218766	76.941857	2026-01-27 19:26:39.150817
218	\N	Buffalo	\N	{35,37,38,42}	20.718517	74.201046	2026-06-16 19:26:39.150941
219	\N	Cattle	\N	{1,6,27,29,33,34,49}	28.516713	81.888503	2024-12-31 19:26:39.151066
220	\N	Horses	\N	{2,43,44,45}	20.170152	83.085530	2024-12-03 19:26:39.151223
221	\N	Geese	\N	{6,12,15,17}	22.930303	82.821807	2026-01-03 19:26:39.151363
222	\N	Buffalo	\N	{35,48,49,50,62}	20.808035	75.826696	2025-05-11 19:26:39.151488
223	\N	Buffalo	\N	{23,24,25,26,61,64}	27.233263	84.449985	2025-04-07 19:26:39.151612
224	\N	Pigs	\N	{35,53,54,55}	27.802695	84.820148	2026-04-15 19:26:39.151794
225	\N	Cattle	\N	{1,27,29,33,34,53,67}	24.654489	73.641436	2025-03-24 19:26:39.151925
226	\N	Horses	\N	{1,12,13}	27.157402	76.364661	2025-03-27 19:26:39.15205
227	\N	Geese	\N	{6,12,15,17}	29.356959	75.552608	2025-05-30 19:26:39.15219
228	\N	Sheep	\N	{7,35,37,38,42}	22.757448	77.983384	2025-08-04 19:26:39.152329
229	\N	Horses	\N	{1,12,13}	18.338251	86.893214	2024-11-07 19:26:39.152456
230	\N	Cattle	\N	{35,37,38,42}	18.459638	86.678339	2025-05-08 19:26:39.152587
231	\N	Sheep	\N	{4,8,60,63,69}	25.384179	86.493720	2026-08-15 19:26:39.152722
232	\N	Cattle	\N	{1,27,29,33,34}	24.585651	83.635757	2025-03-12 19:26:39.152847
233	\N	Cattle	\N	{2,32,43,44,45}	21.613814	72.763991	2025-07-01 19:26:39.152971
234	\N	Buffalo	\N	{35,62,63,66}	19.330295	86.482350	2024-12-31 19:26:39.153095
235	\N	Pigs	\N	{19,31,35,53,54,55}	21.495264	72.025029	2025-09-07 19:26:39.153245
236	\N	Buffalo	\N	{23,24,25,26}	25.972456	73.369823	2025-08-30 19:26:39.153375
237	\N	Cattle	\N	{1,12,13,64}	18.522413	78.190101	2025-08-17 19:26:39.15352
238	\N	Buffalo	\N	{1,27,29,33,34}	22.285127	73.080953	2025-12-31 19:26:39.153654
239	\N	Sheep	\N	{4,8,20,45,69}	18.532028	80.736220	2024-11-14 19:26:39.153797
240	\N	Geese	\N	{6,12,15,17,28,66}	27.737972	73.009609	2025-05-23 19:26:39.153935
241	\N	Warthogs	\N	{1,2,3,6,7}	18.525675	75.191517	2026-07-23 19:26:39.154067
242	\N	Goats	\N	{35,37,38,42,55,65}	21.039765	84.052655	2026-02-20 19:26:39.15422
243	\N	Sheep	\N	{1,27,29,33,34}	28.389579	77.310795	2026-04-29 19:26:39.15436
244	\N	Buffalo	\N	{35,37,38,42,61}	28.735650	78.186316	2026-02-24 19:26:39.154494
245	\N	Pigs	\N	{35,36,48,49,50}	27.613777	83.633301	2026-06-15 19:26:39.154649
246	\N	Horses	\N	{2,39,43,44,45,46}	19.231175	77.246718	2025-11-05 19:26:39.154792
247	\N	Sheep	\N	{1,23,27,29,33,34,60}	26.277178	77.624752	2026-07-22 19:26:39.154943
248	\N	Goats	\N	{4,8,38,58,69}	25.673632	84.663645	2026-07-07 19:26:39.155081
249	\N	Buffalo	\N	{1,12,13,69}	27.613152	82.870570	2026-08-03 19:26:39.15524
250	\N	Geese	\N	{6,12,15,17}	19.514760	75.775926	2024-11-12 19:26:39.155384
251	\N	Goats	\N	{5,35,37,38,42}	25.261138	82.864993	2025-08-20 19:26:39.155541
252	\N	Buffalo	\N	{35,37,38,42}	24.887061	80.471358	2025-07-23 19:26:39.155692
253	\N	Goats	\N	{35,37,38,42}	29.526241	72.414613	2026-02-25 19:26:39.155831
254	\N	Buffalo	\N	{16,35,48,49,50}	21.141320	76.164636	2025-06-04 19:26:39.155986
255	\N	Buffalo	\N	{23,24,25,26,30,67}	19.471649	85.645221	2025-05-29 19:26:39.156347
256	\N	Geese	\N	{6,12,15,17}	27.726159	87.480980	2025-10-11 19:26:39.156802
257	\N	Buffalo	\N	{9,35,39,62,63,66}	28.695980	85.621793	2024-09-05 19:26:39.157211
258	\N	Sheep	\N	{4,8,68,69}	20.690899	87.762121	2026-04-14 19:26:39.157532
259	\N	Buffalo	\N	{23,24,25,26}	22.330758	81.156439	2025-05-13 19:26:39.157795
260	\N	Pigs	\N	{9,12,35,53,54,55}	21.711489	87.993521	2025-05-01 19:26:39.158275
261	\N	Pigs	\N	{10,35,53,54,55}	19.503921	77.072443	2026-06-20 19:26:39.158751
262	\N	Pigs	\N	{17,35,46,48,49,50}	28.535522	84.484207	2024-11-17 19:26:39.159043
263	\N	Sheep	\N	{2,56,57,58}	23.191419	86.571396	2026-07-09 19:26:39.159289
264	\N	Sheep	\N	{1,12,13,25}	19.943604	86.955805	2026-01-16 19:26:39.159495
265	\N	Goats	\N	{35,37,38,42}	21.007264	82.160913	2025-02-16 19:26:39.15966
266	\N	Cattle	\N	{1,13,27,29,33,34,44}	24.030878	74.698174	2025-01-17 19:26:39.159835
267	\N	Turkeys	\N	{6,7,12,15,17,48}	27.902835	72.453976	2026-07-19 19:26:39.160015
268	\N	Buffalo	\N	{27,35,55,62,63,66}	25.417301	72.484574	2024-11-30 19:26:39.160186
269	\N	Pigs	\N	{35,40,53,54,55,66}	20.938535	84.917589	2025-07-15 19:26:39.160348
270	\N	Sheep	\N	{1,27,29,33,34}	26.263363	74.529287	2025-07-05 19:26:39.160492
271	\N	Pigs	\N	{35,48,49,50}	22.082311	74.298699	2025-10-12 19:26:39.160599
272	\N	Goats	\N	{4,8,19,69}	27.127980	80.239682	2026-05-18 19:26:39.160696
273	\N	Cattle	\N	{16,35,37,38,42}	21.209660	75.966702	2026-05-27 19:26:39.160807
274	\N	Warthogs	\N	{1,2,3,6,7,59}	20.979243	85.844920	2026-03-24 19:26:39.160906
275	\N	Goats	\N	{35,37,38,42}	27.157457	79.972249	2025-03-25 19:26:39.161011
276	\N	Pigs	\N	{35,48,49,50,68}	18.278116	87.123725	2025-04-04 19:26:39.161105
277	\N	Sheep	\N	{35,48,49,50}	25.000129	72.778530	2025-11-19 19:26:39.161221
278	\N	Buffalo	\N	{35,38,48,49,50,65}	24.440289	85.554758	2025-06-19 19:26:39.161323
279	\N	Ducks	\N	{6,12,15,17,51,56}	22.391248	78.409306	2025-01-28 19:26:39.161427
280	\N	Pigs	\N	{35,38,53,54,55}	18.882381	80.068088	2025-02-17 19:26:39.161537
281	\N	Buffalo	\N	{1,17,18,27,29,33,34}	29.700994	78.302459	2025-09-21 19:26:39.161649
282	\N	Pigs	\N	{35,53,54,55}	20.388695	80.145960	2025-04-09 19:26:39.161744
283	\N	Pigs	\N	{1,2,3,6,7}	19.644436	77.328651	2025-05-06 19:26:39.161825
284	\N	Pigs	\N	{35,53,54,55}	25.275126	80.248092	2025-10-03 19:26:39.161902
285	\N	Goats	\N	{2,56,57,58}	22.715455	81.864008	2025-11-01 19:26:39.161978
286	\N	Goats	\N	{2,40,56,57,58,67}	23.698711	72.266191	2025-09-29 19:26:39.162058
287	\N	Cattle	\N	{35,41,62,63,66}	27.561058	83.605187	2024-09-29 19:26:39.162235
288	\N	Cattle	\N	{34,35,62,63,64,66}	29.604848	84.526464	2025-01-19 19:26:39.162379
289	\N	Sheep	\N	{2,8,56,57,58,66}	20.046145	82.064404	2024-12-08 19:26:39.162522
290	\N	Horses	\N	{2,6,33,43,44,45}	24.870843	83.208335	2026-02-20 19:26:39.162664
291	\N	Bush Pigs	\N	{1,2,3,6,7,59}	19.817175	83.048004	2025-07-10 19:26:39.16279
292	\N	Pigs	\N	{8,18,35,53,54,55}	24.224199	80.974188	2024-10-25 19:26:39.162917
293	\N	Buffalo	\N	{35,42,48,49,50}	29.480226	79.354617	2025-03-07 19:26:39.163044
294	\N	Goats	\N	{34,35,37,38,42,66}	20.307170	75.944306	2025-02-09 19:26:39.163181
295	\N	Cattle	\N	{1,27,29,33,34,42}	26.458811	83.043839	2025-04-21 19:26:39.163312
296	\N	Buffalo	\N	{35,37,38,39,42}	21.453473	81.175629	2025-02-24 19:26:39.163438
297	\N	Buffalo	\N	{2,20,43,44,45}	21.485432	76.602085	2026-06-15 19:26:39.163577
298	\N	Buffalo	\N	{33,35,37,38,42,66}	20.567842	85.247227	2025-11-30 19:26:39.163777
299	\N	Pigs	\N	{35,53,54,55}	19.310719	83.854256	2026-01-01 19:26:39.163938
300	\N	Cattle	\N	{23,24,25,26,33,34}	18.629893	78.612822	2025-05-08 19:26:39.164073
301	\N	Sheep	\N	{1,12,13}	29.574225	87.646571	2026-03-26 19:26:39.164225
302	\N	Buffalo	\N	{2,27,43,44,45}	27.070933	76.595921	2025-11-15 19:26:39.164377
303	\N	Cattle	\N	{35,62,63,66}	25.827585	75.715523	2026-07-27 19:26:39.164516
304	\N	Geese	\N	{6,12,15,17}	29.207071	72.581438	2025-07-24 19:26:39.164653
305	\N	Sheep	\N	{5,35,39,48,49,50}	18.111206	81.087390	2026-05-17 19:26:39.164794
306	\N	Goats	\N	{35,37,38,42,68}	28.671120	74.147199	2025-04-05 19:26:39.164921
307	\N	Goats	\N	{35,48,49,50}	27.705767	77.290946	2025-05-22 19:26:39.165072
308	\N	Buffalo	\N	{2,24,35,62,63,66}	26.839415	84.652283	2025-01-30 19:26:39.165259
309	\N	Cattle	\N	{35,62,63,66}	25.331454	82.219613	2025-07-15 19:26:39.165417
310	\N	Donkeys	\N	{2,43,44,45}	22.809999	73.526162	2026-04-13 19:26:39.16556
311	\N	Goats	\N	{35,48,49,50}	18.081961	78.137190	2025-06-03 19:26:39.165701
312	\N	Sheep	\N	{1,3,27,29,33,34}	21.138638	77.752833	2026-01-05 19:26:39.165827
313	\N	Pigs	\N	{1,2,3,6,7,45}	19.916602	82.977178	2024-09-13 19:26:39.165973
314	\N	Buffalo	\N	{1,27,29,33,34}	25.664536	87.050170	2025-08-23 19:26:39.166099
315	\N	Sheep	\N	{2,56,57,58}	29.488326	79.650910	2025-05-26 19:26:39.166247
316	\N	Goats	\N	{4,8,63,69}	27.088206	84.831920	2026-01-23 19:26:39.166373
317	\N	Cattle	\N	{23,24,25,26,51,62}	18.937233	81.026700	2026-07-02 19:26:39.166497
318	\N	Pigs	\N	{20,22,35,53,54,55}	21.937412	80.325465	2026-05-07 19:26:39.166629
319	\N	Cattle	\N	{12,35,62,63,66,67}	28.786672	79.127723	2026-07-09 19:26:39.166776
320	\N	Sheep	\N	{35,48,49,50,58,63}	24.766934	80.940755	2024-10-15 19:26:39.166937
321	\N	Buffalo	\N	{1,27,29,33,34}	22.751385	85.063252	2026-01-23 19:26:39.167081
322	\N	Cattle	\N	{2,56,57,58}	23.084369	83.206158	2025-02-26 19:26:39.167224
323	\N	Pigs	\N	{1,2,3,6,7,10}	21.445088	74.879701	2026-04-18 19:26:39.16735
324	\N	Buffalo	\N	{35,50,62,63,66}	23.382446	86.673841	2025-08-13 19:26:39.167474
325	\N	Cattle	\N	{2,19,43,44,45,49}	19.423598	87.885548	2025-07-28 19:26:39.1676
326	\N	Pigs	\N	{1,29,35,53,54,55}	27.074153	87.655851	2025-05-17 19:26:39.167725
327	\N	Buffalo	\N	{30,35,50,62,63,66}	20.970144	77.538556	2025-11-25 19:26:39.16786
328	\N	Cattle	\N	{23,24,25,26}	27.713738	78.707850	2026-08-18 19:26:39.167984
329	\N	Cattle	\N	{23,24,25,26}	19.210761	72.537220	2024-12-30 19:26:39.168115
330	\N	Cattle	\N	{35,62,63,66}	26.886493	78.436246	2026-01-07 19:26:39.168267
331	\N	Pigs	\N	{35,53,54,55}	19.681627	87.895735	2026-01-07 19:26:39.168394
332	\N	Goats	\N	{4,8,33,44,69}	21.621173	74.292167	2024-10-27 19:26:39.168522
333	\N	Pigs	\N	{35,40,53,54,55}	21.301847	80.907490	2025-01-06 19:26:39.168647
334	\N	Sheep	\N	{4,8,57,66,69}	18.562609	77.510637	2024-11-14 19:26:39.168769
335	\N	Buffalo	\N	{35,42,55,62,63,66}	22.899110	76.798216	2026-02-27 19:26:39.168893
336	\N	Pigs	\N	{35,53,54,55}	28.192091	76.811783	2024-09-09 19:26:39.169017
337	\N	Geese	\N	{6,12,15,17}	24.748631	87.484579	2025-02-10 19:26:39.169161
338	\N	Pigs	\N	{32,35,53,54,55}	21.059948	77.284208	2026-06-15 19:26:39.169317
339	\N	Goats	\N	{35,48,49,50}	24.427626	85.270501	2026-07-13 19:26:39.169448
340	\N	Sheep	\N	{1,7,11,27,29,33,34}	20.257960	84.187143	2024-10-16 19:26:39.169574
341	\N	Pigs	\N	{27,35,53,54,55}	28.433686	77.327429	2026-08-19 19:26:39.169701
342	\N	Cattle	\N	{16,23,24,25,26,66}	28.973296	83.130021	2024-09-13 19:26:39.169825
343	\N	Buffalo	\N	{23,24,25,26}	24.624952	84.408222	2025-08-10 19:26:39.16995
344	\N	Buffalo	\N	{35,41,47,48,49,50}	21.138740	80.205065	2025-04-12 19:26:39.170074
345	\N	Cattle	\N	{35,42,48,49,50,65}	28.971966	77.931279	2025-07-07 19:26:39.170213
346	\N	Wild Boars	\N	{1,2,3,6,7,8,24}	21.129289	86.956132	2025-01-18 19:26:39.170354
347	\N	Goats	\N	{4,8,22,69}	20.354301	75.680298	2025-01-28 19:26:39.17049
348	\N	Buffalo	\N	{23,24,25,26,37,48}	27.160328	79.817938	2024-11-15 19:26:39.170615
349	\N	Goats	\N	{4,8,24,69}	26.793267	77.634819	2026-04-13 19:26:39.170739
350	\N	Goats	\N	{4,8,69}	29.002793	80.674190	2024-11-15 19:26:39.17086
351	\N	Pigs	\N	{1,2,3,6,7}	29.342257	82.691449	2026-08-28 19:26:39.170981
352	\N	Horses	\N	{2,10,31,43,44,45}	26.486035	72.146263	2025-04-04 19:26:39.171116
353	\N	Goats	\N	{35,48,49,50}	25.414023	82.668076	2024-12-11 19:26:39.171291
354	\N	Pigs	\N	{35,48,49,50}	18.079348	80.826297	2026-08-22 19:26:39.171429
355	\N	Warthogs	\N	{1,2,3,6,7,8,42}	24.026592	83.165745	2025-06-20 19:26:39.171566
356	\N	Chickens	\N	{6,12,15,17}	24.292625	75.855501	2024-12-08 19:26:39.171702
357	\N	Pigs	\N	{35,36,53,54,55}	27.539236	73.264308	2025-07-15 19:26:39.171839
358	\N	Buffalo	\N	{35,48,49,50}	29.882796	75.613716	2024-10-03 19:26:39.171969
359	\N	Cattle	\N	{1,12,13}	22.863340	78.034713	2025-05-04 19:26:39.172101
360	\N	Pigs	\N	{1,2,3,6,7,16,27}	23.998301	78.942554	2025-09-29 19:26:39.172282
361	\N	Cattle	\N	{2,7,31,56,57,58}	20.537005	85.889870	2025-01-31 19:26:39.17255
362	\N	Goats	\N	{35,48,49,50}	29.089911	82.950860	2025-11-20 19:26:39.172826
363	\N	Pigs	\N	{35,53,54,55}	29.145196	77.031755	2026-02-03 19:26:39.173095
364	\N	Sheep	\N	{2,11,52,56,57,58}	21.591323	81.023331	2025-01-31 19:26:39.17342
365	\N	Donkeys	\N	{2,19,43,44,45}	27.485977	83.028969	2026-06-15 19:26:39.173693
366	\N	Pigs	\N	{35,53,54,55}	19.172229	75.714304	2026-06-18 19:26:39.173913
367	\N	Buffalo	\N	{4,35,37,38,42}	25.609475	84.536770	2025-05-30 19:26:39.174163
368	\N	Sheep	\N	{35,48,49,50,53}	23.182175	82.875118	2024-10-27 19:26:39.174396
369	\N	Cattle	\N	{2,33,39,43,44,45}	26.557302	73.312608	2026-03-30 19:26:39.174678
370	\N	Horses	\N	{2,42,43,44,45,54}	22.328403	73.464327	2025-10-23 19:26:39.174894
371	\N	Goats	\N	{14,35,48,49,50}	19.590084	74.998269	2025-06-01 19:26:39.175101
372	\N	Pigs	\N	{35,53,54,55}	18.315143	77.662629	2026-05-31 19:26:39.175466
373	\N	Goats	\N	{2,3,56,57,58}	21.502168	78.204793	2026-06-09 19:26:39.175622
374	\N	Sheep	\N	{4,8,24,51,69}	20.034021	76.302703	2025-12-03 19:26:39.17576
375	\N	Sheep	\N	{35,48,49,50}	20.006489	76.415390	2025-11-01 19:26:39.17589
376	\N	Cattle	\N	{33,35,48,49,50}	29.330668	83.534391	2025-04-14 19:26:39.176019
377	\N	Sheep	\N	{2,15,56,57,58}	19.625874	72.108278	2025-07-25 19:26:39.176169
378	\N	Buffalo	\N	{35,37,38,42,61}	22.016835	85.047608	2024-11-06 19:26:39.176312
379	\N	Sheep	\N	{2,43,56,57,58}	25.238535	83.124677	2025-05-01 19:26:39.176444
380	\N	Cattle	\N	{35,37,38,42,45}	21.497378	83.119324	2025-04-19 19:26:39.176569
381	\N	Sheep	\N	{2,50,56,57,58}	21.363602	84.573865	2025-08-26 19:26:39.176699
382	\N	Sheep	\N	{1,5,12,13,27}	29.436055	79.385956	2024-09-08 19:26:39.176825
383	\N	Buffalo	\N	{9,23,24,25,26}	27.827587	84.730509	2025-07-12 19:26:39.17695
384	\N	Buffalo	\N	{35,62,63,66}	25.600032	75.872339	2024-10-29 19:26:39.177073
385	\N	Geese	\N	{6,11,12,15,17}	23.388801	81.566942	2025-01-15 19:26:39.177215
386	\N	Buffalo	\N	{2,6,43,44,45,51}	26.419611	84.996752	2025-01-03 19:26:39.177349
387	\N	Cattle	\N	{35,62,63,66}	27.227449	82.521626	2025-09-05 19:26:39.177508
388	\N	Chickens	\N	{6,12,15,17,47,56}	29.588601	78.887289	2026-08-24 19:26:39.177682
389	\N	Horses	\N	{1,12,13}	24.128115	80.300764	2025-01-17 19:26:39.177824
390	\N	Sheep	\N	{4,8,50,69}	22.693610	84.357476	2025-01-09 19:26:39.177975
391	\N	Sheep	\N	{4,5,8,69}	23.793253	76.726916	2026-06-08 19:26:39.178117
392	\N	Sheep	\N	{1,12,13,43}	22.116800	84.548320	2025-03-19 19:26:39.178307
393	\N	Goats	\N	{13,35,48,49,50}	23.257991	83.148212	2025-10-12 19:26:39.178468
394	\N	Horses	\N	{1,12,13}	27.722231	73.841364	2025-09-17 19:26:39.178603
395	\N	Cattle	\N	{22,32,35,62,63,66}	24.191927	80.830565	2025-09-30 19:26:39.17873
396	\N	Pigs	\N	{30,35,53,54,55}	27.573069	82.076165	2026-02-25 19:26:39.178857
397	\N	Buffalo	\N	{4,35,62,63,66}	26.848660	86.129558	2025-05-31 19:26:39.178992
398	\N	Buffalo	\N	{1,2,56,57,58}	26.456827	75.292552	2024-09-13 19:26:39.179118
399	\N	Cattle	\N	{1,12,13,27,50}	21.911819	79.320807	2025-12-09 19:26:39.179267
400	\N	Buffalo	\N	{35,42,51,62,63,66}	25.335701	81.392075	2025-09-12 19:26:39.179394
401	\N	Buffalo	\N	{23,35,37,38,42,43}	29.024191	81.442694	2024-10-15 19:26:39.179536
402	\N	Ducks	\N	{6,12,15,17}	20.862873	73.871182	2025-08-17 19:26:39.179661
403	\N	Sheep	\N	{4,8,52,56,69}	25.157110	81.196897	2025-06-27 19:26:39.179786
404	\N	Geese	\N	{6,12,15,17,26,27}	23.875704	74.244745	2025-10-16 19:26:39.17991
405	\N	Buffalo	\N	{35,48,49,50}	28.386267	87.229471	2025-04-25 19:26:39.180038
406	\N	Turkeys	\N	{6,12,15,17,69}	25.836837	78.546150	2025-04-18 19:26:39.180183
407	\N	Buffalo	\N	{2,23,43,44,45}	18.992048	72.493771	2026-01-21 19:26:39.180329
408	\N	Cattle	\N	{1,27,29,32,33,34}	24.451303	74.691344	2025-05-23 19:26:39.180475
409	\N	Buffalo	\N	{2,16,36,56,57,58}	27.301356	85.172525	2025-08-24 19:26:39.180758
410	\N	Pigs	\N	{28,35,53,54,55,61}	29.877309	73.638663	2024-11-03 19:26:39.180919
411	\N	Buffalo	\N	{23,24,25,26}	23.396788	77.577232	2026-06-06 19:26:39.181053
412	\N	Cattle	\N	{35,48,49,50}	20.518538	83.801808	2024-09-28 19:26:39.181199
413	\N	Buffalo	\N	{35,37,38,42}	25.393814	84.557589	2026-02-04 19:26:39.18137
414	\N	Warthogs	\N	{1,2,3,6,7,27,41}	21.883843	83.264860	2025-11-11 19:26:39.181507
415	\N	Goats	\N	{2,14,19,56,57,58}	29.553264	84.571057	2026-07-05 19:26:39.181648
416	\N	Buffalo	\N	{1,27,29,33,34}	26.417118	74.123054	2026-04-07 19:26:39.181788
417	\N	Goats	\N	{4,8,69}	27.137683	82.819753	2025-04-20 19:26:39.181914
418	\N	Ducks	\N	{6,12,15,17,53,58}	23.423901	82.138044	2026-05-31 19:26:39.182042
419	\N	Donkeys	\N	{2,43,44,45,52,63}	29.403049	77.236628	2026-09-01 19:26:39.182219
420	\N	Sheep	\N	{4,8,48,61,69}	28.201275	84.730847	2025-07-23 19:26:39.182401
421	\N	Buffalo	\N	{23,24,25,26}	23.936579	77.165842	2025-11-17 19:26:39.182568
422	\N	Cattle	\N	{35,37,38,42,48,67}	28.729856	84.196064	2026-07-18 19:26:39.182702
423	\N	Buffalo	\N	{1,12,13}	19.490846	85.722426	2025-06-09 19:26:39.182839
424	\N	Cattle	\N	{26,35,48,49,50}	29.948329	86.550515	2024-11-07 19:26:39.182984
425	\N	Cattle	\N	{1,13,27,29,33,34}	25.855056	76.006228	2025-08-19 19:26:39.183113
426	\N	Cattle	\N	{35,62,63,66}	22.756099	76.888148	2024-09-17 19:26:39.183267
427	\N	Buffalo	\N	{12,13,23,24,25,26}	18.013036	79.628907	2026-04-21 19:26:39.183394
428	\N	Sheep	\N	{2,3,56,57,58,61}	18.096751	77.497186	2026-05-03 19:26:39.183532
429	\N	Horses	\N	{2,11,43,44,45}	20.747362	73.429297	2026-05-22 19:26:39.18366
430	\N	Horses	\N	{1,12,13,42}	19.645552	84.375368	2026-04-20 19:26:39.183784
431	\N	Cattle	\N	{35,62,63,66}	24.366099	72.135596	2024-11-07 19:26:39.183908
432	\N	Geese	\N	{6,12,15,17,32}	25.536960	74.421986	2025-07-09 19:26:39.184032
433	\N	Buffalo	\N	{2,56,57,58}	19.040256	73.607442	2026-04-30 19:26:39.184168
434	\N	Buffalo	\N	{2,56,57,58,59}	21.774044	74.237283	2025-11-24 19:26:39.184304
435	\N	Cattle	\N	{35,62,63,66}	24.640760	81.600126	2024-12-20 19:26:39.18443
436	\N	Buffalo	\N	{1,27,29,33,34}	28.174705	82.534486	2025-10-30 19:26:39.184557
437	\N	Cattle	\N	{23,24,25,26,42,55}	25.754037	84.540826	2026-01-01 19:26:39.184691
438	\N	Pigs	\N	{35,48,49,50}	20.892981	82.209317	2026-06-23 19:26:39.184817
439	\N	Pigs	\N	{35,42,53,54,55}	19.583795	85.773024	2025-01-29 19:26:39.184951
440	\N	Donkeys	\N	{2,24,43,44,45,65}	29.453436	84.325873	2026-08-17 19:26:39.185076
441	\N	Cattle	\N	{2,56,57,58}	21.146223	72.637230	2026-07-04 19:26:39.18522
442	\N	Donkeys	\N	{2,43,44,45,58,69}	23.082903	78.436439	2024-11-17 19:26:39.185351
443	\N	Pigs	\N	{11,35,53,54,55}	21.718883	80.180875	2026-02-07 19:26:39.185485
444	\N	Ducks	\N	{6,10,12,15,17}	21.722034	78.999777	2026-01-02 19:26:39.18561
445	\N	Wild Boars	\N	{1,2,3,6,7}	29.095533	73.855785	2024-12-16 19:26:39.185747
446	\N	Cattle	\N	{2,24,56,57,58}	19.433316	83.326410	2024-09-15 19:26:39.18593
447	\N	Wild Boars	\N	{1,2,3,6,7,50}	24.276064	84.527794	2025-12-12 19:26:39.186071
448	\N	Ducks	\N	{6,12,15,17}	26.997317	85.975361	2026-05-06 19:26:39.186214
449	\N	Warthogs	\N	{1,2,3,6,7,40}	24.286251	76.207194	2025-01-21 19:26:39.186344
450	\N	Cattle	\N	{35,60,62,63,66}	24.129383	72.887026	2025-01-31 19:26:39.186469
451	\N	Ducks	\N	{6,12,15,17}	21.061393	73.646479	2025-01-24 19:26:39.18661
452	\N	Cattle	\N	{35,62,63,66}	26.889360	72.041096	2026-08-22 19:26:39.186733
453	\N	Cattle	\N	{23,24,25,26,51}	22.595754	74.401355	2026-07-29 19:26:39.186868
454	\N	Pigs	\N	{35,53,54,55}	21.861624	78.660106	2025-10-11 19:26:39.186995
455	\N	Cattle	\N	{1,17,27,29,33,34,53}	24.024491	86.431056	2026-03-04 19:26:39.187119
456	\N	Cattle	\N	{9,23,24,25,26}	28.523895	85.856516	2025-10-20 19:26:39.187284
457	\N	Sheep	\N	{2,35,37,38,42,63}	22.427032	76.665521	2025-10-27 19:26:39.18744
458	\N	Sheep	\N	{4,8,50,69}	25.100291	79.893771	2026-02-15 19:26:39.187585
459	\N	Sheep	\N	{4,8,69}	18.076535	78.560578	2026-01-08 19:26:39.187712
460	\N	Pigs	\N	{2,35,44,53,54,55}	18.017544	82.516862	2025-10-24 19:26:39.18784
461	\N	Sheep	\N	{1,12,13,34,57}	23.904347	72.958321	2026-04-11 19:26:39.187992
462	\N	Goats	\N	{4,8,69}	18.526803	75.703561	2025-03-20 19:26:39.188153
463	\N	Donkeys	\N	{2,12,43,44,45}	24.969248	80.086844	2024-11-20 19:26:39.188365
464	\N	Cattle	\N	{2,9,43,44,45,60}	25.949327	74.091333	2025-11-09 19:26:39.188537
465	\N	Sheep	\N	{1,27,29,33,34,47}	21.816693	76.351294	2026-06-19 19:26:39.188686
466	\N	Cattle	\N	{14,20,23,24,25,26}	19.267893	79.193068	2025-10-17 19:26:39.188825
467	\N	Cattle	\N	{2,28,43,44,45,50}	23.423005	79.413546	2026-05-04 19:26:39.188977
468	\N	Sheep	\N	{1,7,12,13,42}	20.580249	85.705172	2026-04-05 19:26:39.189126
469	\N	Sheep	\N	{1,12,13,54}	24.161516	82.834934	2025-12-11 19:26:39.189314
470	\N	Chickens	\N	{6,12,15,17,62}	24.671445	80.801934	2026-05-30 19:26:39.189495
471	\N	Cattle	\N	{35,48,49,50}	19.457439	72.986707	2026-01-19 19:26:39.189689
472	\N	Turkeys	\N	{6,12,15,17,52}	26.235423	87.001198	2026-06-09 19:26:39.189831
473	\N	Goats	\N	{2,56,57,58}	18.261602	73.031553	2024-11-11 19:26:39.189963
474	\N	Sheep	\N	{35,48,49,50}	28.860936	85.269699	2025-09-29 19:26:39.190093
475	\N	Cattle	\N	{1,8,12,13}	20.015871	81.182147	2025-07-26 19:26:39.19026
476	\N	Cattle	\N	{35,48,49,50,59}	20.073687	75.435458	2026-02-24 19:26:39.190397
477	\N	Sheep	\N	{1,21,27,29,33,34}	18.415793	81.906825	2025-12-26 19:26:39.19055
478	\N	Buffalo	\N	{35,54,62,63,66}	28.593343	79.664495	2026-06-06 19:26:39.190704
479	\N	Sheep	\N	{1,27,29,33,34}	23.030818	82.282440	2025-03-14 19:26:39.190833
480	\N	Cattle	\N	{23,24,25,26,50}	23.756213	84.502962	2025-09-16 19:26:39.190977
481	\N	Goats	\N	{2,36,56,57,58}	20.157790	77.102041	2026-01-22 19:26:39.191114
482	\N	Warthogs	\N	{1,2,3,6,7}	27.703847	79.546950	2025-09-02 19:26:39.191302
483	\N	Sheep	\N	{2,56,57,58}	19.201612	82.509831	2025-12-05 19:26:39.191494
484	\N	Pigs	\N	{35,53,54,55}	24.908305	87.722634	2025-08-02 19:26:39.19164
485	\N	Cattle	\N	{35,37,38,42}	20.838614	77.088070	2024-09-19 19:26:39.191778
486	\N	Sheep	\N	{19,35,37,38,42,50}	24.757307	75.011739	2025-04-17 19:26:39.191915
487	\N	Pigs	\N	{35,53,54,55}	23.885237	73.444118	2026-01-08 19:26:39.192048
488	\N	Sheep	\N	{2,56,57,58}	24.317382	72.010936	2024-12-14 19:26:39.1922
489	\N	Cattle	\N	{23,24,25,26,27}	29.025369	85.508545	2025-10-07 19:26:39.192352
490	\N	Pigs	\N	{1,2,3,6,7}	25.039310	86.675586	2026-05-13 19:26:39.192495
491	\N	Pigs	\N	{35,53,54,55}	22.483089	87.070771	2025-07-25 19:26:39.192635
492	\N	Cattle	\N	{2,40,56,57,58}	21.871238	87.613771	2025-06-13 19:26:39.192762
493	\N	Buffalo	\N	{23,35,42,62,63,66}	26.486195	80.991637	2024-12-14 19:26:39.192891
494	\N	Cattle	\N	{23,35,37,38,42,53}	21.681879	83.015975	2026-04-26 19:26:39.193024
495	\N	Chickens	\N	{5,6,12,15,17,55}	20.184981	77.091471	2024-12-16 19:26:39.193183
496	\N	Cattle	\N	{19,23,24,25,26}	21.974021	73.244906	2025-09-13 19:26:39.193321
497	\N	Cattle	\N	{12,35,37,38,42,47}	23.359559	76.243399	2025-12-22 19:26:39.193466
498	\N	Sheep	\N	{4,8,35,69}	27.444240	83.526617	2026-07-16 19:26:39.193597
499	\N	Buffalo	\N	{2,23,43,44,45,58}	28.614624	79.889312	2025-08-12 19:26:39.193723
500	\N	Buffalo	\N	{35,37,38,42}	27.945684	84.619680	2025-01-20 19:26:39.193848
501	\N	Cattle	\N	{35,62,63,66}	23.415449	84.787113	2026-07-31 19:26:39.193972
502	\N	Cattle	\N	{1,27,29,33,34,39}	29.419946	73.187206	2026-03-13 19:26:39.194104
503	\N	Horses	\N	{2,11,13,43,44,45}	22.055407	87.764418	2025-04-27 19:26:39.19426
504	\N	Sheep	\N	{4,8,24,69}	25.287812	78.947206	2026-07-11 19:26:39.19439
505	\N	Horses	\N	{1,12,13}	29.692781	78.548478	2025-02-13 19:26:39.194525
506	\N	Goats	\N	{4,8,39,41,69}	20.850579	72.794167	2025-01-26 19:26:39.194647
507	\N	Pigs	\N	{35,53,54,55}	18.654058	72.061049	2026-06-06 19:26:39.194771
508	\N	Buffalo	\N	{1,27,28,29,33,34,67}	19.163843	75.311248	2024-11-19 19:26:39.194895
509	\N	Cattle	\N	{1,16,27,29,33,34}	21.700241	78.359478	2025-04-21 19:26:39.195028
510	\N	Buffalo	\N	{35,62,63,66}	25.702397	78.200434	2025-08-20 19:26:39.195165
511	\N	Donkeys	\N	{2,43,44,45}	23.349303	76.212735	2025-05-15 19:26:39.1953
512	\N	Cattle	\N	{1,9,27,29,33,34}	19.813568	83.143535	2026-05-27 19:26:39.195423
513	\N	Horses	\N	{1,12,13,33,56}	24.643223	85.452755	2025-03-17 19:26:39.195553
514	\N	Buffalo	\N	{2,32,43,44,45,65}	21.586225	78.316870	2026-07-30 19:26:39.19569
515	\N	Pigs	\N	{35,53,54,55}	29.391058	79.184636	2026-03-16 19:26:39.195817
516	\N	Cattle	\N	{23,24,25,26}	18.512111	73.253896	2024-10-04 19:26:39.195939
517	\N	Horses	\N	{2,20,35,43,44,45}	21.836994	83.633648	2026-06-27 19:26:39.196062
518	\N	Buffalo	\N	{1,12,13,45,54}	28.279490	80.315011	2026-08-22 19:26:39.196202
519	\N	Goats	\N	{4,8,69}	22.973309	74.371196	2025-01-09 19:26:39.19633
520	\N	Cattle	\N	{2,56,57,58}	24.752205	73.615847	2025-11-15 19:26:39.196506
521	\N	Pigs	\N	{34,35,53,54,55}	22.596522	79.769357	2024-12-19 19:26:39.196634
522	\N	Cattle	\N	{35,48,49,50}	21.304970	74.301643	2024-12-19 19:26:39.196767
523	\N	Buffalo	\N	{35,62,63,66}	22.749513	86.063322	2024-09-26 19:26:39.196893
524	\N	Cattle	\N	{23,24,25,26,39,65}	28.764376	72.323726	2025-10-28 19:26:39.197016
525	\N	Sheep	\N	{1,14,27,29,33,34}	29.669960	75.647319	2025-10-31 19:26:39.197187
526	\N	Goats	\N	{4,8,37,69}	26.745593	81.679666	2026-06-04 19:26:39.197343
527	\N	Buffalo	\N	{23,24,25,26}	28.961194	78.514726	2025-04-25 19:26:39.197476
528	\N	Pigs	\N	{35,53,54,55}	24.183236	74.543559	2025-10-20 19:26:39.1976
529	\N	Goats	\N	{4,8,69}	27.366197	80.388579	2025-01-29 19:26:39.197723
530	\N	Wild Boars	\N	{1,2,3,6,7}	28.502167	75.211628	2026-07-06 19:26:39.197858
531	\N	Cattle	\N	{7,23,24,25,26}	29.016373	83.274143	2025-11-27 19:26:39.197996
532	\N	Buffalo	\N	{16,35,37,38,42,55}	26.174092	75.871010	2025-04-21 19:26:39.198128
533	\N	Buffalo	\N	{2,56,57,58}	29.526245	79.593317	2025-02-16 19:26:39.198297
534	\N	Goats	\N	{35,37,38,42}	28.051845	76.138559	2024-09-28 19:26:39.198434
535	\N	Horses	\N	{1,12,13}	22.638788	74.606518	2025-01-26 19:26:39.198565
536	\N	Cattle	\N	{23,24,25,26,31,33}	21.229003	78.552115	2026-08-14 19:26:39.198698
537	\N	Cattle	\N	{17,35,62,63,66}	25.768459	81.618271	2026-08-26 19:26:39.198841
538	\N	Buffalo	\N	{23,24,25,26,40,44}	23.085682	78.023607	2025-09-11 19:26:39.199247
539	\N	Goats	\N	{35,48,49,50}	23.600376	82.835139	2024-12-04 19:26:39.199713
540	\N	Cattle	\N	{2,43,44,45}	24.138165	82.597687	2025-08-16 19:26:39.200046
541	\N	Pigs	\N	{14,35,53,54,55}	23.780861	77.380538	2025-11-24 19:26:39.200346
542	\N	Buffalo	\N	{34,35,62,63,66}	25.873435	87.235005	2024-11-05 19:26:39.200542
543	\N	Cattle	\N	{1,27,29,33,34}	24.207523	75.844833	2026-07-07 19:26:39.20071
544	\N	Buffalo	\N	{2,19,42,56,57,58}	26.655398	82.486409	2025-11-05 19:26:39.200934
545	\N	Sheep	\N	{1,27,29,33,34,55}	26.840785	81.328379	2025-01-26 19:26:39.201184
546	\N	Buffalo	\N	{23,24,25,26,33,65}	28.878318	82.749896	2025-04-02 19:26:39.201462
547	\N	Cattle	\N	{1,25,27,29,33,34,43}	19.171237	74.047106	2025-12-13 19:26:39.20173
548	\N	Sheep	\N	{4,8,14,45,69}	20.667042	75.573247	2025-10-24 19:26:39.201997
549	\N	Donkeys	\N	{2,35,43,44,45}	25.026848	79.420170	2026-05-06 19:26:39.202286
550	\N	Cattle	\N	{10,35,48,49,50,65}	28.673113	80.007638	2024-10-06 19:26:39.202555
551	\N	Donkeys	\N	{2,8,43,44,45}	28.450190	74.412455	2026-02-10 19:26:39.202786
552	\N	Buffalo	\N	{19,35,37,38,42,63}	21.796601	83.450695	2026-06-13 19:26:39.203042
553	\N	Goats	\N	{23,35,42,48,49,50}	25.613988	72.075416	2025-11-27 19:26:39.203257
554	\N	Cattle	\N	{21,23,24,25,26,67}	27.422531	84.476039	2026-04-24 19:26:39.203531
555	\N	Buffalo	\N	{2,53,56,57,58,59}	23.148305	79.638404	2026-08-30 19:26:39.203799
556	\N	Wild Boars	\N	{1,2,3,5,6,7,53}	28.704077	84.109564	2025-03-09 19:26:39.204058
557	\N	Cattle	\N	{1,23,24,25,26,36}	20.715189	86.031762	2025-10-19 19:26:39.204275
558	\N	Chickens	\N	{6,12,15,17,69}	25.064048	74.672323	2026-07-19 19:26:39.204673
559	\N	Sheep	\N	{1,27,29,33,34,49}	23.203983	82.988482	2026-04-19 19:26:39.205286
560	\N	Buffalo	\N	{25,35,37,38,42}	19.978602	86.510308	2025-07-17 19:26:39.205761
561	\N	Wild Boars	\N	{1,2,3,6,7}	26.726026	74.099292	2026-08-12 19:26:39.20624
562	\N	Sheep	\N	{2,56,57,58}	22.399097	82.408646	2026-07-27 19:26:39.206684
563	\N	Donkeys	\N	{2,8,15,43,44,45}	25.842811	72.315868	2024-09-27 19:26:39.206877
564	\N	Buffalo	\N	{1,12,13,52}	19.483141	76.043813	2024-09-15 19:26:39.207032
565	\N	Turkeys	\N	{2,6,12,15,17,43}	23.050457	73.615678	2025-03-20 19:26:39.207194
566	\N	Buffalo	\N	{1,19,27,29,33,34,59}	27.967833	73.678628	2024-12-10 19:26:39.207351
567	\N	Horses	\N	{1,12,13}	27.417121	79.963825	2024-12-19 19:26:39.207569
568	\N	Buffalo	\N	{23,24,25,26,30,50}	26.441241	76.725619	2026-07-25 19:26:39.207766
569	\N	Pigs	\N	{35,53,54,55}	26.258447	79.690623	2026-01-06 19:26:39.207969
570	\N	Pigs	\N	{1,2,3,6,7,17,20}	28.022786	82.704351	2026-04-04 19:26:39.208194
571	\N	Cattle	\N	{1,12,13,16,36}	25.732041	79.308020	2025-11-04 19:26:39.208533
572	\N	Sheep	\N	{1,27,29,33,34}	19.197707	74.795229	2026-07-25 19:26:39.20887
573	\N	Sheep	\N	{1,27,29,33,34,46,60}	26.862482	73.519976	2026-07-19 19:26:39.20923
574	\N	Wild Boars	\N	{1,2,3,6,7,27,48}	22.290329	79.003432	2024-12-06 19:26:39.209666
575	\N	Buffalo	\N	{1,27,29,33,34}	22.471466	77.483564	2026-05-10 19:26:39.210027
576	\N	Buffalo	\N	{2,36,43,44,45}	28.028500	83.038439	2025-05-02 19:26:39.210406
577	\N	Horses	\N	{2,43,44,45}	19.590139	83.622578	2026-03-24 19:26:39.210747
578	\N	Buffalo	\N	{1,12,13,60,65}	20.175127	78.076012	2025-09-01 19:26:39.211081
579	\N	Cattle	\N	{2,18,56,57,58,66}	29.044776	73.807000	2025-07-09 19:26:39.21144
580	\N	Cattle	\N	{35,48,49,50}	21.139354	77.027807	2024-09-12 19:26:39.211627
581	\N	Cattle	\N	{13,35,45,62,63,66}	23.194175	83.626431	2025-04-28 19:26:39.211762
582	\N	Buffalo	\N	{35,37,38,42}	28.068396	80.933508	2024-12-15 19:26:39.211901
583	\N	Pigs	\N	{1,2,3,6,7,26,66}	28.222454	85.910650	2026-06-19 19:26:39.212025
584	\N	Goats	\N	{35,48,49,50}	21.970738	76.450514	2025-04-02 19:26:39.212154
585	\N	Buffalo	\N	{23,24,25,26,35}	18.945967	79.107022	2025-01-25 19:26:39.2123
586	\N	Cattle	\N	{35,48,49,50,62}	21.792738	87.690732	2024-11-03 19:26:39.212428
587	\N	Pigs	\N	{1,2,3,6,7,58}	18.429983	80.785581	2026-06-02 19:26:39.212563
588	\N	Goats	\N	{2,28,56,57,58,63}	29.404262	77.813480	2026-07-10 19:26:39.212696
589	\N	Buffalo	\N	{23,24,25,26,65}	26.599897	77.812713	2025-05-28 19:26:39.212824
590	\N	Cattle	\N	{1,2,12,13,32}	22.096285	85.278142	2025-11-09 19:26:39.212949
591	\N	Pigs	\N	{6,14,35,53,54,55}	28.762525	79.878754	2025-07-11 19:26:39.213074
592	\N	Horses	\N	{1,12,13,28,29}	19.448950	85.635110	2026-01-26 19:26:39.21323
593	\N	Sheep	\N	{14,35,45,48,49,50}	27.085792	72.744006	2024-11-24 19:26:39.213419
594	\N	Cattle	\N	{35,60,62,63,66}	25.901480	87.299045	2026-04-19 19:26:39.213554
595	\N	Cattle	\N	{7,35,48,49,50,60}	28.065793	79.726911	2025-04-01 19:26:39.21369
596	\N	Turkeys	\N	{6,12,15,17,18,21}	22.648867	81.608736	2025-10-09 19:26:39.213835
597	\N	Pigs	\N	{32,35,53,54,55}	21.283151	87.417497	2025-11-06 19:26:39.21398
598	\N	Sheep	\N	{35,48,49,50}	22.952946	83.200229	2025-03-28 19:26:39.214111
599	\N	Buffalo	\N	{1,27,29,31,33,34,46}	20.410669	81.986681	2025-11-10 19:26:39.214261
600	\N	Buffalo	\N	{17,23,35,62,63,66}	24.046721	83.108992	2025-10-08 19:26:39.214396
601	\N	Sheep	\N	{4,8,64,69}	24.993675	87.082778	2024-09-06 19:26:39.214526
602	\N	Donkeys	\N	{2,3,43,44,45}	24.272760	72.404354	2026-04-08 19:26:39.214673
603	\N	Pigs	\N	{1,2,3,6,7}	21.203739	84.568515	2025-11-14 19:26:39.214816
604	\N	Buffalo	\N	{35,62,63,66}	28.072582	83.049518	2025-11-05 19:26:39.214958
605	\N	Cattle	\N	{23,24,25,26,62}	19.229760	85.888566	2025-02-05 19:26:39.215098
606	\N	Buffalo	\N	{23,24,25,26}	24.131068	84.749338	2024-09-21 19:26:39.215249
607	\N	Buffalo	\N	{1,8,27,29,33,34,54}	22.650656	87.307232	2024-10-02 19:26:39.215382
608	\N	Sheep	\N	{35,37,38,42}	26.924040	75.249396	2025-06-07 19:26:39.215512
609	\N	Buffalo	\N	{23,24,25,26,29,30}	21.530133	74.838814	2024-10-04 19:26:39.215637
610	\N	Sheep	\N	{1,12,13}	26.820954	73.909661	2026-07-24 19:26:39.215767
611	\N	Donkeys	\N	{2,18,35,43,44,45}	19.931146	85.536227	2026-08-29 19:26:39.215914
612	\N	Buffalo	\N	{6,20,35,37,38,42}	19.844441	77.162080	2026-07-13 19:26:39.216094
613	\N	Buffalo	\N	{35,47,62,63,66}	18.874570	83.322905	2025-03-14 19:26:39.216275
614	\N	Cattle	\N	{9,23,24,25,26,69}	19.912446	80.689282	2025-07-17 19:26:39.216428
615	\N	Horses	\N	{1,12,13}	28.600761	82.613352	2025-09-29 19:26:39.216555
616	\N	Goats	\N	{35,37,38,42}	29.403699	81.892490	2025-05-05 19:26:39.216679
617	\N	Pigs	\N	{35,53,54,55}	26.027262	79.130676	2024-11-15 19:26:39.216803
618	\N	Sheep	\N	{2,56,57,58}	26.190616	77.134992	2026-05-10 19:26:39.216926
619	\N	Donkeys	\N	{2,5,38,43,44,45}	28.936031	85.153745	2025-08-16 19:26:39.217051
620	\N	Pigs	\N	{6,35,53,54,55}	21.557208	82.424451	2025-10-10 19:26:39.217231
621	\N	Pigs	\N	{35,53,54,55}	20.008738	87.300419	2025-03-02 19:26:39.21736
622	\N	Pigs	\N	{9,27,35,53,54,55}	26.044022	84.377316	2024-10-02 19:26:39.217494
623	\N	Cattle	\N	{2,43,44,45}	24.453051	83.243886	2025-06-15 19:26:39.217621
624	\N	Cattle	\N	{4,20,35,62,63,66}	23.510703	77.307446	2026-06-06 19:26:39.217745
625	\N	Cattle	\N	{1,12,13}	27.530577	80.929347	2025-01-23 19:26:39.217871
626	\N	Buffalo	\N	{23,24,25,26,54}	23.413508	78.471168	2025-10-15 19:26:39.217995
627	\N	Bush Pigs	\N	{1,2,3,4,6,7,21}	25.697073	81.893590	2025-01-12 19:26:39.21812
628	\N	Pigs	\N	{1,2,3,6,7,19}	21.478039	82.974059	2024-12-21 19:26:39.218283
629	\N	Horses	\N	{1,12,13,52}	22.741359	82.571571	2025-05-06 19:26:39.218417
630	\N	Turkeys	\N	{6,12,15,17}	26.961047	84.748327	2025-02-22 19:26:39.218542
631	\N	Buffalo	\N	{1,27,29,33,34}	21.576678	86.191650	2024-11-09 19:26:39.218665
632	\N	Sheep	\N	{16,19,35,37,38,42}	18.501278	81.163498	2025-07-27 19:26:39.218789
633	\N	Pigs	\N	{27,35,53,54,55}	26.979559	86.456742	2025-09-16 19:26:39.218913
634	\N	Buffalo	\N	{19,21,23,24,25,26}	20.207913	81.870159	2025-12-19 19:26:39.219037
635	\N	Cattle	\N	{23,24,25,26}	26.051735	81.076682	2026-07-10 19:26:39.219171
636	\N	Pigs	\N	{10,35,39,53,54,55}	26.060223	76.011002	2026-02-13 19:26:39.219301
637	\N	Goats	\N	{4,8,48,69}	19.538582	82.487568	2026-05-24 19:26:39.219442
638	\N	Buffalo	\N	{1,27,29,33,34}	28.801423	77.084575	2025-05-30 19:26:39.219567
639	\N	Goats	\N	{20,35,37,38,42,51}	27.692397	87.338543	2026-03-15 19:26:39.219691
640	\N	Warthogs	\N	{1,2,3,6,7}	27.427921	83.395186	2024-11-16 19:26:39.219818
641	\N	Donkeys	\N	{2,19,43,44,45}	26.154962	77.305007	2025-04-30 19:26:39.219942
642	\N	Pigs	\N	{35,41,48,49,50}	23.843657	73.741322	2024-11-11 19:26:39.220107
643	\N	Cattle	\N	{2,19,56,57,58}	28.695564	75.142911	2024-12-01 19:26:39.220521
644	\N	Cattle	\N	{1,12,13}	28.195047	82.106024	2025-01-16 19:26:39.220851
645	\N	Buffalo	\N	{2,6,29,56,57,58}	24.619128	80.695509	2025-02-28 19:26:39.221159
646	\N	Sheep	\N	{35,48,49,50,55}	20.679680	84.354317	2025-11-10 19:26:39.221551
647	\N	Geese	\N	{6,12,14,15,17,55}	22.366387	72.169467	2026-01-02 19:26:39.222098
648	\N	Sheep	\N	{2,19,56,57,58,62}	19.910669	81.061716	2025-02-01 19:26:39.222624
649	\N	Cattle	\N	{35,47,62,63,65,66}	18.485038	84.183558	2026-01-09 19:26:39.223171
650	\N	Horses	\N	{1,12,13,33}	18.513701	75.308385	2025-08-30 19:26:39.223695
651	\N	Buffalo	\N	{2,7,43,44,45}	18.478856	82.376396	2026-05-21 19:26:39.224049
652	\N	Goats	\N	{4,8,25,36,69}	22.519915	78.056296	2025-01-10 19:26:39.224441
653	\N	Cattle	\N	{33,35,50,62,63,66}	29.672089	75.566388	2025-07-15 19:26:39.22492
654	\N	Goats	\N	{35,37,38,42,66}	28.646063	72.105563	2026-04-14 19:26:39.225358
655	\N	Sheep	\N	{35,48,49,50}	18.925059	82.295632	2026-01-30 19:26:39.225583
656	\N	Turkeys	\N	{6,12,15,17}	22.346675	83.476843	2026-05-05 19:26:39.225769
657	\N	Cattle	\N	{35,44,62,63,66}	26.643068	79.704266	2025-05-01 19:26:39.225947
658	\N	Sheep	\N	{21,35,48,49,50,57}	18.269352	72.690309	2025-01-24 19:26:39.226121
659	\N	Sheep	\N	{2,56,57,58}	25.554485	72.627054	2025-01-25 19:26:39.226301
660	\N	Chickens	\N	{6,12,15,17}	21.099116	74.880601	2025-07-15 19:26:39.22657
661	\N	Cattle	\N	{2,12,38,56,57,58}	20.599121	81.704414	2025-05-09 19:26:39.22693
662	\N	Sheep	\N	{35,48,49,50}	27.964363	81.613419	2025-01-15 19:26:39.227305
663	\N	Ducks	\N	{6,12,15,17}	26.690242	77.482740	2025-05-27 19:26:39.227673
664	\N	Cattle	\N	{2,56,57,58}	22.538536	74.115411	2026-08-18 19:26:39.228046
665	\N	Buffalo	\N	{23,24,25,26}	25.266132	74.838755	2024-12-13 19:26:39.228469
666	\N	Cattle	\N	{2,17,56,57,58,69}	19.118280	82.550282	2024-12-25 19:26:39.22886
667	\N	Pigs	\N	{35,53,54,55,58,60}	22.444529	72.695013	2025-03-10 19:26:39.2294
668	\N	Horses	\N	{2,43,44,45,53}	22.206214	84.873937	2024-09-20 19:26:39.229705
669	\N	Cattle	\N	{2,19,56,57,58}	21.054216	84.253742	2026-06-10 19:26:39.22984
670	\N	Buffalo	\N	{1,27,29,33,34,38,58}	20.268252	83.346381	2026-08-27 19:26:39.229976
671	\N	Cattle	\N	{1,2,50,56,57,58}	25.854553	83.004268	2025-10-15 19:26:39.230107
672	\N	Donkeys	\N	{2,43,44,45}	19.857343	82.425215	2025-12-18 19:26:39.230254
673	\N	Buffalo	\N	{1,27,29,33,34,52}	25.342568	87.868779	2025-07-24 19:26:39.230391
674	\N	Buffalo	\N	{23,24,25,26,27,66}	22.442556	80.878582	2025-12-18 19:26:39.230539
675	\N	Buffalo	\N	{1,27,29,33,34,56}	26.829389	85.679983	2024-10-28 19:26:39.230699
676	\N	Sheep	\N	{1,12,13,24}	19.203343	80.133497	2025-09-22 19:26:39.23087
677	\N	Pigs	\N	{35,53,54,55}	22.669244	82.174026	2026-06-02 19:26:39.231011
678	\N	Geese	\N	{6,12,14,15,17,60}	18.768965	75.548324	2026-06-14 19:26:39.231169
679	\N	Cattle	\N	{2,51,53,56,57,58}	25.367587	80.336089	2024-09-05 19:26:39.231319
680	\N	Cattle	\N	{2,56,57,58}	25.683496	79.023553	2026-02-09 19:26:39.231457
681	\N	Buffalo	\N	{35,62,63,66}	18.403312	81.592239	2025-03-24 19:26:39.231604
682	\N	Sheep	\N	{4,6,8,24,69}	22.316880	82.480306	2026-03-26 19:26:39.231737
683	\N	Horses	\N	{1,12,13,49}	26.035945	78.487215	2026-02-10 19:26:39.231877
684	\N	Pigs	\N	{9,12,35,53,54,55}	24.595112	83.618219	2025-02-08 19:26:39.232005
685	\N	Goats	\N	{2,37,56,57,58}	20.715546	87.408914	2025-05-26 19:26:39.232129
686	\N	Cattle	\N	{2,24,43,44,45}	22.885616	73.703439	2026-06-21 19:26:39.232286
687	\N	Pigs	\N	{15,35,53,54,55}	27.635307	87.307350	2025-03-02 19:26:39.232416
688	\N	Goats	\N	{2,50,56,57,58,61}	24.758023	84.319475	2025-09-21 19:26:39.232547
689	\N	Pigs	\N	{4,35,48,49,50,66}	19.395220	73.080868	2024-11-24 19:26:39.232701
690	\N	Cattle	\N	{23,24,25,26,57}	29.465348	80.264067	2026-08-25 19:26:39.232851
691	\N	Goats	\N	{4,8,69}	21.447475	78.382890	2025-09-18 19:26:39.233012
692	\N	Sheep	\N	{1,12,13,44}	22.242455	86.309060	2025-12-02 19:26:39.233154
693	\N	Turkeys	\N	{6,12,15,17,30}	20.818336	75.872904	2025-12-06 19:26:39.233288
694	\N	Cattle	\N	{23,24,25,26}	28.019286	85.381355	2025-09-04 19:26:39.233412
695	\N	Chickens	\N	{6,12,15,17}	29.042258	82.812994	2024-10-24 19:26:39.233548
696	\N	Buffalo	\N	{35,48,49,50}	27.170931	80.663583	2026-07-22 19:26:39.233671
697	\N	Goats	\N	{35,42,48,49,50,68}	28.777454	86.095796	2025-01-23 19:26:39.233795
698	\N	Sheep	\N	{1,27,29,33,34}	29.812736	86.656109	2025-11-21 19:26:39.233921
699	\N	Horses	\N	{2,8,18,43,44,45}	24.308825	78.770814	2025-02-27 19:26:39.234051
700	\N	Warthogs	\N	{1,2,3,6,7,28}	23.486352	73.925891	2025-03-22 19:26:39.234198
701	\N	Goats	\N	{2,27,35,48,49,50}	22.553136	73.611965	2025-08-29 19:26:39.234349
702	\N	Goats	\N	{2,56,57,58}	24.582761	75.794226	2025-05-09 19:26:39.234491
703	\N	Goats	\N	{2,25,56,57,58}	23.985240	75.368520	2024-09-16 19:26:39.234645
704	\N	Goats	\N	{35,37,38,39,42}	23.408748	81.142555	2025-01-22 19:26:39.234775
705	\N	Cattle	\N	{35,62,63,66}	26.649786	84.865401	2025-02-12 19:26:39.2349
706	\N	Buffalo	\N	{2,43,44,45}	19.750125	87.346367	2026-04-03 19:26:39.235025
707	\N	Cattle	\N	{35,48,49,50}	23.058248	74.151547	2024-11-27 19:26:39.235173
708	\N	Pigs	\N	{35,40,53,54,55}	21.011688	85.736032	2026-07-17 19:26:39.235311
709	\N	Cattle	\N	{2,9,22,43,44,45}	20.585608	76.068635	2024-11-28 19:26:39.235436
710	\N	Buffalo	\N	{1,12,13,37,46}	22.331544	80.965601	2025-12-14 19:26:39.235561
711	\N	Sheep	\N	{16,35,37,38,42}	22.213086	82.873374	2024-12-22 19:26:39.235685
712	\N	Cattle	\N	{23,24,25,26,50}	21.901083	80.167112	2025-06-03 19:26:39.235808
713	\N	Buffalo	\N	{1,12,13,40,63}	25.580546	74.317573	2026-03-16 19:26:39.235935
714	\N	Buffalo	\N	{35,53,62,63,66}	28.186809	73.141505	2026-03-22 19:26:39.236063
715	\N	Cattle	\N	{35,37,38,42,45}	25.836157	83.366936	2024-12-23 19:26:39.236209
716	\N	Buffalo	\N	{35,58,62,63,66}	27.371688	87.020317	2025-01-10 19:26:39.236344
717	\N	Pigs	\N	{22,35,53,54,55}	20.206634	72.369617	2026-01-06 19:26:39.236469
718	\N	Buffalo	\N	{11,27,35,62,63,66}	20.002926	73.648149	2026-06-30 19:26:39.236594
719	\N	Buffalo	\N	{35,48,49,50}	18.316379	78.352200	2026-06-10 19:26:39.236718
720	\N	Horses	\N	{1,12,13,14,23}	25.857992	86.167541	2025-10-22 19:26:39.236841
721	\N	Cattle	\N	{23,24,25,26,41,61}	25.517768	74.100434	2026-03-13 19:26:39.236966
722	\N	Pigs	\N	{1,2,3,6,7,47,51}	28.370894	79.475096	2025-02-27 19:26:39.237105
723	\N	Buffalo	\N	{1,19,27,29,33,34}	29.634507	83.161966	2026-03-06 19:26:39.237248
724	\N	Buffalo	\N	{2,41,56,57,58,60}	28.907078	79.706427	2026-01-14 19:26:39.237379
725	\N	Buffalo	\N	{1,12,13,50}	22.946446	74.491481	2026-08-24 19:26:39.237503
726	\N	Wild Boars	\N	{1,2,3,6,7,42}	23.630375	72.133074	2025-04-18 19:26:39.23763
727	\N	Goats	\N	{35,48,49,50}	27.190430	84.767436	2024-12-31 19:26:39.237754
728	\N	Cattle	\N	{23,24,25,26,29,52}	22.940830	80.968870	2025-07-26 19:26:39.237875
729	\N	Cattle	\N	{23,24,25,26,53,54}	20.647109	73.267356	2024-12-02 19:26:39.238
730	\N	Buffalo	\N	{23,24,25,26,39}	22.954847	85.655712	2026-03-01 19:26:39.238141
731	\N	Ducks	\N	{6,12,15,17}	25.642713	81.883671	2025-11-29 19:26:39.238283
732	\N	Goats	\N	{4,8,69}	21.847725	74.434389	2025-03-05 19:26:39.238418
733	\N	Wild Boars	\N	{1,2,3,6,7}	21.385374	74.000627	2025-06-12 19:26:39.238602
734	\N	Sheep	\N	{4,8,69}	19.082364	72.235598	2026-01-24 19:26:39.238754
735	\N	Buffalo	\N	{35,37,38,42,68}	29.975561	79.418951	2026-08-02 19:26:39.238898
736	\N	Sheep	\N	{35,37,38,42}	18.672460	84.410447	2026-06-22 19:26:39.239038
737	\N	Pigs	\N	{35,53,54,55}	20.306308	85.464629	2025-08-09 19:26:39.23918
738	\N	Pigs	\N	{1,2,3,6,7,37,55}	27.254704	79.087375	2026-07-31 19:26:39.239341
739	\N	Buffalo	\N	{13,23,24,25,26,31}	23.673907	82.903077	2025-10-19 19:26:39.239497
740	\N	Cattle	\N	{6,16,35,37,38,42}	21.039753	82.216320	2026-02-12 19:26:39.239651
741	\N	Sheep	\N	{15,28,35,37,38,42}	20.831590	78.946586	2026-08-19 19:26:39.240039
742	\N	Ducks	\N	{6,12,15,17,20,55}	27.469725	72.142878	2026-07-22 19:26:39.240261
743	\N	Buffalo	\N	{2,21,49,56,57,58}	27.249564	75.979556	2025-04-10 19:26:39.240426
744	\N	Horses	\N	{1,9,12,13,49}	25.734899	83.221250	2026-05-17 19:26:39.240576
745	\N	Geese	\N	{6,12,15,17}	21.800875	80.933607	2024-11-12 19:26:39.240745
746	\N	Buffalo	\N	{3,25,35,37,38,42}	26.271000	77.730680	2026-04-19 19:26:39.240879
747	\N	Cattle	\N	{1,27,29,33,34,62}	24.708297	80.683745	2025-04-20 19:26:39.241023
748	\N	Cattle	\N	{23,24,25,26,46,49}	26.788829	76.405191	2024-12-29 19:26:39.241176
749	\N	Pigs	\N	{35,53,54,55}	24.373649	79.190147	2025-12-08 19:26:39.241327
750	\N	Pigs	\N	{1,35,53,54,55}	27.311015	80.095324	2026-02-26 19:26:39.241599
751	\N	Warthogs	\N	{1,2,3,6,7,36,47}	26.652043	82.532631	2025-03-01 19:26:39.242007
752	\N	Horses	\N	{2,21,43,44,45,68}	25.356471	77.161601	2024-11-16 19:26:39.242427
753	\N	Sheep	\N	{35,37,38,42}	24.278406	73.066877	2026-04-24 19:26:39.242842
754	\N	Chickens	\N	{6,12,15,17}	19.284662	75.065866	2026-08-02 19:26:39.243299
755	\N	Buffalo	\N	{2,34,56,57,58,67}	18.589028	75.531565	2026-06-23 19:26:39.2437
756	\N	Wild Boars	\N	{1,2,3,6,7,16,68}	23.616710	82.222667	2025-08-30 19:26:39.244077
757	\N	Pigs	\N	{8,35,53,54,55}	27.883716	76.253050	2026-07-24 19:26:39.244529
758	\N	Sheep	\N	{4,8,12,69}	29.335242	87.369388	2026-05-27 19:26:39.244684
759	\N	Sheep	\N	{1,12,13,28,53}	20.317433	82.510024	2025-01-28 19:26:39.244814
760	\N	Cattle	\N	{14,35,55,62,63,66}	27.195401	81.225019	2024-10-13 19:26:39.244945
761	\N	Pigs	\N	{35,48,49,50}	20.001712	74.886345	2025-07-19 19:26:39.24509
762	\N	Pigs	\N	{21,35,53,54,55,61}	29.202240	86.439760	2025-02-17 19:26:39.245242
763	\N	Goats	\N	{35,37,38,42,60}	27.913860	77.175215	2025-12-31 19:26:39.245376
764	\N	Sheep	\N	{2,34,56,57,58}	22.320103	79.238456	2025-07-24 19:26:39.245502
765	\N	Pigs	\N	{1,2,3,6,7,8}	24.211312	87.894592	2025-10-29 19:26:39.245636
766	\N	Warthogs	\N	{1,2,3,6,7}	20.577874	77.038475	2024-09-27 19:26:39.24576
767	\N	Buffalo	\N	{1,14,21,27,29,33,34}	18.452836	77.690492	2026-04-15 19:26:39.24589
768	\N	Sheep	\N	{1,27,29,33,34,35,37}	21.074926	76.804839	2025-01-27 19:26:39.246017
769	\N	Horses	\N	{2,11,43,44,45,46}	27.514850	74.766440	2024-09-27 19:26:39.246161
770	\N	Sheep	\N	{4,6,8,41,69}	26.769472	81.220539	2026-06-15 19:26:39.2463
771	\N	Warthogs	\N	{1,2,3,6,7,61}	22.998261	85.885298	2026-01-14 19:26:39.246433
772	\N	Sheep	\N	{4,8,9,51,69}	21.657401	72.658916	2025-02-28 19:26:39.246712
773	\N	Sheep	\N	{2,56,57,58,69}	26.373224	74.451160	2024-10-14 19:26:39.247054
774	\N	Goats	\N	{4,8,67,69}	19.080995	78.910971	2025-07-27 19:26:39.247426
775	\N	Turkeys	\N	{6,12,13,15,17}	23.710256	83.925041	2025-02-19 19:26:39.247956
776	\N	Donkeys	\N	{2,43,44,45}	22.782324	78.951858	2024-09-19 19:26:39.248346
777	\N	Turkeys	\N	{6,12,15,17,30}	23.854333	82.435975	2026-02-15 19:26:39.24864
778	\N	Pigs	\N	{35,53,54,55}	18.859728	84.428350	2025-10-07 19:26:39.248781
779	\N	Cattle	\N	{35,62,63,66}	26.060971	78.776650	2025-09-12 19:26:39.248919
780	\N	Buffalo	\N	{4,23,24,25,26}	27.236176	74.708084	2025-09-10 19:26:39.249052
781	\N	Buffalo	\N	{2,20,56,57,58,61}	18.538531	85.090751	2026-02-11 19:26:39.249196
782	\N	Buffalo	\N	{35,62,63,66}	27.092805	85.644226	2026-05-11 19:26:39.249337
783	\N	Sheep	\N	{4,8,69}	29.387291	86.827675	2025-11-13 19:26:39.249461
784	\N	Warthogs	\N	{1,2,3,6,7,20,45}	23.400739	72.363970	2026-02-01 19:26:39.249588
785	\N	Sheep	\N	{4,8,69}	24.557091	84.005682	2025-02-19 19:26:39.249726
786	\N	Buffalo	\N	{3,19,35,48,49,50}	22.519280	86.496645	2025-03-13 19:26:39.249878
787	\N	Warthogs	\N	{1,2,3,6,7}	18.721321	75.211137	2024-09-20 19:26:39.250024
788	\N	Goats	\N	{2,56,57,58}	23.579530	87.122824	2026-06-27 19:26:39.250202
789	\N	Donkeys	\N	{2,15,43,44,45,51}	18.228940	85.878567	2024-11-08 19:26:39.250342
790	\N	Horses	\N	{2,14,43,44,45}	28.846465	79.754594	2024-12-31 19:26:39.250473
791	\N	Pigs	\N	{35,53,54,55}	20.386502	87.468662	2025-02-06 19:26:39.250598
792	\N	Sheep	\N	{4,8,69}	20.968706	80.470646	2025-09-27 19:26:39.25072
793	\N	Pigs	\N	{3,21,35,48,49,50}	22.161359	77.630609	2024-12-02 19:26:39.250844
794	\N	Cattle	\N	{1,9,27,29,33,34,41}	25.509508	86.058836	2026-08-04 19:26:39.250974
795	\N	Pigs	\N	{35,53,54,55}	19.820498	86.354805	2024-10-31 19:26:39.251101
796	\N	Chickens	\N	{6,12,15,17,34,53}	23.008000	81.166377	2025-06-24 19:26:39.251257
797	\N	Buffalo	\N	{1,27,29,33,34,63}	24.506805	75.308116	2026-04-15 19:26:39.251397
798	\N	Sheep	\N	{2,56,57,58}	21.707981	83.282182	2025-03-16 19:26:39.251524
799	\N	Geese	\N	{6,12,15,17}	25.874781	81.037509	2026-03-26 19:26:39.251646
800	\N	Sheep	\N	{16,24,35,37,38,42}	21.811171	86.074210	2026-08-04 19:26:39.251769
801	\N	Buffalo	\N	{35,37,38,42,43}	23.316054	86.940296	2024-11-20 19:26:39.251893
802	\N	Goats	\N	{4,8,69}	27.349295	73.708343	2026-02-26 19:26:39.252028
803	\N	Warthogs	\N	{1,2,3,6,7,9,35}	22.311136	83.010261	2025-05-03 19:26:39.252247
804	\N	Geese	\N	{6,12,15,17,28,52}	28.225553	79.863130	2026-04-16 19:26:39.252502
805	\N	Turkeys	\N	{6,12,15,17}	18.386755	84.232622	2026-08-19 19:26:39.252722
806	\N	Sheep	\N	{1,27,29,33,34}	26.908400	87.811895	2026-02-06 19:26:39.252948
807	\N	Sheep	\N	{1,12,13,66}	26.254352	85.868398	2025-12-25 19:26:39.253179
808	\N	Buffalo	\N	{2,43,44,45}	25.295159	85.189256	2025-10-18 19:26:39.253354
809	\N	Cattle	\N	{2,15,43,44,45,62}	23.482805	86.044271	2025-12-26 19:26:39.253489
810	\N	Pigs	\N	{6,35,51,53,54,55}	24.193520	82.090377	2026-07-15 19:26:39.253621
811	\N	Buffalo	\N	{23,24,25,26,55}	28.612771	84.378832	2025-11-15 19:26:39.253746
812	\N	Sheep	\N	{35,39,48,49,50}	25.357611	72.872747	2025-03-23 19:26:39.253868
813	\N	Geese	\N	{6,12,14,15,17,62}	26.671761	73.810745	2025-01-12 19:26:39.25399
814	\N	Sheep	\N	{4,8,55,69}	21.881531	72.398594	2025-05-27 19:26:39.254114
815	\N	Sheep	\N	{2,13,56,57,58}	21.000988	83.067479	2024-09-05 19:26:39.254324
816	\N	Chickens	\N	{6,12,15,17}	19.369979	79.190375	2025-08-28 19:26:39.254462
817	\N	Buffalo	\N	{1,12,13,24,69}	22.544144	78.089712	2026-03-13 19:26:39.25466
818	\N	Cattle	\N	{35,37,38,42}	28.425822	74.861868	2024-09-04 19:26:39.254825
819	\N	Bush Pigs	\N	{1,2,3,6,7,45}	26.761941	87.375458	2025-11-12 19:26:39.254987
820	\N	Cattle	\N	{35,62,63,66}	28.782503	87.366942	2026-08-31 19:26:39.255128
821	\N	Goats	\N	{2,56,57,58}	23.503712	85.686577	2025-02-24 19:26:39.255307
822	\N	Bush Pigs	\N	{1,2,3,6,7}	20.602486	82.551530	2025-05-27 19:26:39.25545
823	\N	Buffalo	\N	{2,43,44,45}	25.214599	72.105168	2025-02-20 19:26:39.25567
824	\N	Buffalo	\N	{1,8,27,29,30,33,34}	20.218080	72.881023	2025-09-11 19:26:39.255979
825	\N	Wild Boars	\N	{1,2,3,6,7}	26.003959	85.408231	2025-11-02 19:26:39.256307
826	\N	Sheep	\N	{35,37,38,42}	19.306652	87.899763	2026-03-22 19:26:39.256757
827	\N	Buffalo	\N	{23,35,60,62,63,66}	26.992018	77.763018	2026-07-29 19:26:39.257297
828	\N	Horses	\N	{1,12,13,51}	28.770357	85.124236	2025-06-23 19:26:39.257706
829	\N	Pigs	\N	{35,53,54,55,65}	19.614549	83.113911	2025-11-26 19:26:39.257892
830	\N	Buffalo	\N	{8,27,35,37,38,42}	19.311627	83.675656	2024-11-28 19:26:39.258064
831	\N	Pigs	\N	{35,38,53,54,55}	23.124643	85.564768	2025-12-12 19:26:39.258291
832	\N	Pigs	\N	{35,53,54,55}	25.371480	79.942351	2024-11-25 19:26:39.258487
833	\N	Pigs	\N	{35,48,49,50}	28.603964	75.723546	2025-11-10 19:26:39.258652
834	\N	Cattle	\N	{23,24,25,26}	18.287842	82.007372	2026-05-06 19:26:39.2588
835	\N	Sheep	\N	{4,8,55,56,69}	18.545906	77.594401	2024-11-20 19:26:39.258964
836	\N	Cattle	\N	{23,24,25,26,30,41}	21.053010	73.085377	2025-10-31 19:26:39.259161
837	\N	Pigs	\N	{35,53,54,55}	19.366041	77.332526	2025-07-25 19:26:39.259337
838	\N	Sheep	\N	{4,8,69}	20.328187	85.341205	2024-10-15 19:26:39.259549
839	\N	Pigs	\N	{35,48,49,50}	25.747827	79.703928	2024-11-30 19:26:39.259807
840	\N	Buffalo	\N	{35,48,49,50,64}	27.407868	78.623249	2026-07-08 19:26:39.260067
841	\N	Pigs	\N	{3,35,42,53,54,55}	20.499150	82.967893	2025-09-06 19:26:39.260357
842	\N	Sheep	\N	{1,5,12,13}	22.069829	78.003852	2025-03-05 19:26:39.260676
843	\N	Geese	\N	{6,12,15,17}	25.142302	85.833499	2025-10-23 19:26:39.260997
844	\N	Goats	\N	{4,6,8,37,69}	22.966435	79.952871	2026-01-03 19:26:39.261346
845	\N	Buffalo	\N	{28,35,37,38,42}	24.301205	74.800204	2025-08-16 19:26:39.261673
846	\N	Wild Boars	\N	{1,2,3,6,7}	23.325289	72.398956	2025-04-27 19:26:39.261816
847	\N	Pigs	\N	{35,53,54,55}	22.081391	79.735551	2025-03-16 19:26:39.26208
848	\N	Sheep	\N	{1,27,29,33,34}	27.233777	73.572025	2025-03-24 19:26:39.26232
849	\N	Cattle	\N	{35,62,63,66}	26.694848	79.349895	2024-09-03 19:26:39.262486
850	\N	Pigs	\N	{35,53,54,55}	21.731776	72.704479	2025-01-03 19:26:39.262664
851	\N	Horses	\N	{1,7,12,13}	19.237234	84.258883	2025-10-19 19:26:39.262982
852	\N	Warthogs	\N	{1,2,3,6,7,32,47}	20.406666	76.585078	2025-03-07 19:26:39.263241
853	\N	Buffalo	\N	{16,35,36,37,38,42}	19.791849	76.378190	2026-08-19 19:26:39.26346
854	\N	Cattle	\N	{2,56,57,58}	24.510345	80.789851	2025-11-30 19:26:39.263926
855	\N	Ducks	\N	{6,12,15,17,26,36}	18.854914	81.812206	2025-09-22 19:26:39.264298
856	\N	Pigs	\N	{35,53,54,55}	19.560888	79.531769	2024-10-12 19:26:39.264574
857	\N	Pigs	\N	{1,2,3,6,7,12}	19.033435	78.270668	2024-09-12 19:26:39.264783
858	\N	Buffalo	\N	{2,41,47,56,57,58}	21.987985	75.170354	2024-10-17 19:26:39.264977
859	\N	Pigs	\N	{17,35,53,54,55}	19.114994	84.837608	2024-09-18 19:26:39.265174
860	\N	Cattle	\N	{35,41,48,49,50}	26.213736	83.363454	2025-05-15 19:26:39.265431
861	\N	Sheep	\N	{35,48,49,50}	19.724660	86.331214	2025-12-13 19:26:39.265765
862	\N	Buffalo	\N	{35,37,38,42}	26.395375	82.642890	2025-10-06 19:26:39.266035
863	\N	Pigs	\N	{35,48,49,50}	18.784382	73.806193	2025-05-01 19:26:39.266303
864	\N	Sheep	\N	{35,46,48,49,50}	25.253283	74.038304	2026-05-21 19:26:39.266559
865	\N	Cattle	\N	{2,11,43,44,45}	27.509171	80.523929	2025-07-20 19:26:39.266818
866	\N	Buffalo	\N	{2,56,57,58}	25.450498	80.767184	2025-04-28 19:26:39.267073
867	\N	Cattle	\N	{2,28,43,44,45}	27.766988	81.455523	2025-06-15 19:26:39.267362
868	\N	Goats	\N	{2,24,32,56,57,58}	25.951347	73.246310	2024-09-05 19:26:39.267625
869	\N	Buffalo	\N	{2,56,57,58}	25.105958	79.406535	2025-02-12 19:26:39.267792
870	\N	Buffalo	\N	{1,12,13}	21.696429	78.492699	2024-12-30 19:26:39.267923
871	\N	Buffalo	\N	{1,12,13,67}	25.739869	72.983716	2026-01-24 19:26:39.268046
872	\N	Chickens	\N	{6,12,15,17}	25.930577	79.247591	2025-11-09 19:26:39.26819
873	\N	Buffalo	\N	{2,43,44,45}	20.467940	86.038806	2025-11-01 19:26:39.268326
874	\N	Goats	\N	{2,46,56,57,58}	29.883471	81.323632	2024-12-16 19:26:39.268461
875	\N	Pigs	\N	{35,53,54,55}	28.230062	72.998569	2025-02-18 19:26:39.268587
876	\N	Pigs	\N	{1,2,3,6,7,20,51}	28.334974	85.850874	2026-01-06 19:26:39.26871
877	\N	Buffalo	\N	{2,42,43,44,45,53}	22.872392	78.963041	2026-01-30 19:26:39.268895
878	\N	Cattle	\N	{18,35,62,63,66}	20.258722	78.153521	2025-08-31 19:26:39.269043
879	\N	Horses	\N	{2,18,43,44,45}	19.611329	73.147936	2026-08-18 19:26:39.269181
880	\N	Geese	\N	{6,12,15,17,22,60}	19.015961	82.275886	2025-07-05 19:26:39.269314
881	\N	Buffalo	\N	{24,35,48,49,50}	23.452732	78.785995	2025-05-31 19:26:39.26944
882	\N	Donkeys	\N	{2,43,44,45}	20.229492	81.673172	2025-01-20 19:26:39.269669
883	\N	Sheep	\N	{35,36,48,49,50,69}	22.930054	80.738660	2025-08-24 19:26:39.269988
884	\N	Pigs	\N	{1,2,3,6,7,53,67}	19.357972	79.704527	2024-09-26 19:26:39.270613
885	\N	Sheep	\N	{1,12,13,39,63}	24.203395	80.373709	2024-12-18 19:26:39.271048
886	\N	Sheep	\N	{1,11,12,13}	26.208888	80.627155	2025-01-18 19:26:39.271369
887	\N	Buffalo	\N	{1,27,29,33,34}	28.843023	80.560532	2026-08-23 19:26:39.271714
888	\N	Pigs	\N	{35,44,48,49,50,65}	23.052193	87.369301	2025-11-06 19:26:39.271994
889	\N	Cattle	\N	{1,27,29,33,34}	26.340614	81.562184	2025-10-27 19:26:39.272376
890	\N	Goats	\N	{4,8,69}	25.551601	81.250257	2025-01-25 19:26:39.272761
891	\N	Warthogs	\N	{1,2,3,6,7,9,42}	23.817122	74.029141	2026-06-17 19:26:39.273119
892	\N	Sheep	\N	{1,27,29,33,34}	25.389573	76.403474	2025-12-14 19:26:39.273767
893	\N	Pigs	\N	{1,2,3,6,7,25,28}	25.909868	77.916269	2026-03-08 19:26:39.274154
894	\N	Buffalo	\N	{1,27,29,33,34}	23.819022	84.789952	2026-08-01 19:26:39.274388
895	\N	Sheep	\N	{35,37,38,42}	25.146529	85.147580	2025-04-14 19:26:39.274778
896	\N	Buffalo	\N	{2,43,44,45}	25.928007	83.615985	2026-03-16 19:26:39.275158
897	\N	Buffalo	\N	{23,24,25,26}	25.707133	84.087743	2026-05-08 19:26:39.275456
898	\N	Wild Boars	\N	{1,2,3,6,7,57}	23.714783	79.620260	2025-03-07 19:26:39.275715
899	\N	Buffalo	\N	{23,24,25,26,54,65}	21.151502	80.487074	2025-06-15 19:26:39.276129
900	\N	Warthogs	\N	{1,2,3,6,7,54}	26.141921	87.388204	2024-10-04 19:26:39.276545
\.


--
-- Data for Name: lab_reports; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.lab_reports (lab_report_id, report_id, lab_technician_id, confirmed_disease_id, test_method, test_results, is_final_truth, used_in_training, verified_at) FROM stdin;
1	1	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
2	2	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
3	3	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
4	4	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
5	5	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
6	6	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
7	7	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
8	8	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
9	9	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
10	10	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
11	11	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
12	12	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
13	13	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
14	14	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
15	15	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
16	16	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
17	17	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
18	18	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
19	19	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
20	20	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
21	21	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
22	22	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
23	23	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
24	24	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
25	25	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
26	26	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
27	27	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
28	28	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
29	29	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
30	30	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
31	31	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
32	32	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
33	33	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
34	34	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
35	35	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
36	36	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
37	37	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
38	38	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
39	39	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
40	40	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
41	41	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
42	42	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
43	43	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
44	44	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
45	45	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
46	46	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
47	47	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
48	48	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
49	49	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
50	50	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
51	51	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
52	52	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
53	53	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
54	54	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
55	55	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
56	56	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
57	57	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
58	58	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
59	59	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
60	60	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
61	61	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
62	62	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
63	63	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
64	64	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
65	65	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
66	66	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
67	67	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
68	68	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
69	69	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
70	70	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
71	71	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
72	72	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
73	73	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
74	74	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
75	75	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
76	76	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
77	77	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
78	78	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
79	79	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
80	80	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
81	81	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
82	82	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
83	83	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
84	84	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
85	85	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
86	86	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
87	87	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
88	88	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
89	89	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
90	90	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
91	91	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
92	92	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
93	93	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
94	94	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
95	95	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
96	96	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
97	97	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
98	98	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
99	99	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
100	100	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
101	101	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
102	102	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
103	103	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
104	104	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
105	105	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
106	106	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
107	107	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
108	108	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
109	109	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
110	110	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
111	111	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
112	112	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
113	113	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
114	114	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
115	115	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
116	116	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
117	117	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
118	118	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
119	119	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
120	120	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
121	121	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
122	122	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
123	123	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
124	124	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
125	125	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
126	126	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
127	127	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
128	128	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
129	129	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
130	130	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
131	131	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
132	132	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
133	133	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
134	134	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
135	135	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
136	136	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
137	137	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
138	138	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
139	139	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
140	140	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
141	141	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
142	142	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
143	143	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
144	144	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
145	145	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
146	146	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
147	147	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
148	148	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
149	149	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
150	150	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
151	151	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
152	152	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
153	153	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
154	154	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
155	155	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
156	156	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
157	157	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
158	158	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
159	159	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
160	160	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
161	161	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
162	162	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
163	163	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
164	164	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
165	165	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
166	166	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
167	167	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
168	168	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
169	169	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
170	170	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
171	171	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
172	172	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
173	173	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
174	174	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
175	175	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
176	176	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
177	177	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
178	178	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
179	179	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
180	180	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
181	181	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
182	182	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
183	183	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
184	184	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
185	185	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
186	186	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
187	187	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
188	188	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
189	189	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
190	190	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
191	191	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
192	192	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
193	193	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
194	194	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
195	195	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
196	196	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
197	197	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
198	198	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
199	199	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
200	200	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
201	201	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
202	202	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
203	203	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
204	204	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
205	205	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
206	206	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
207	207	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
208	208	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
209	209	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
210	210	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
211	211	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
212	212	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
213	213	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
214	214	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
215	215	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
216	216	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
217	217	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
218	218	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
219	219	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
220	220	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
221	221	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
222	222	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
223	223	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
224	224	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
225	225	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
226	226	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
227	227	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
228	228	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
229	229	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
230	230	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
231	231	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
232	232	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
233	233	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
234	234	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
235	235	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
236	236	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
237	237	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
238	238	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
239	239	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
240	240	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
241	241	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
242	242	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
243	243	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
244	244	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
245	245	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
246	246	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
247	247	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
248	248	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
249	249	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
250	250	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
251	251	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
252	252	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
253	253	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
254	254	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
255	255	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
256	256	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
257	257	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
258	258	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
259	259	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
260	260	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
261	261	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
262	262	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
263	263	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
264	264	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
265	265	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
266	266	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
267	267	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
268	268	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
269	269	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
270	270	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
271	271	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
272	272	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
273	273	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
274	274	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
275	275	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
276	276	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
277	277	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
278	278	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
279	279	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
280	280	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
281	281	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
282	282	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
283	283	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
284	284	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
285	285	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
286	286	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
287	287	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
288	288	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
289	289	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
290	290	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
291	291	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
292	292	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
293	293	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
294	294	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
295	295	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
296	296	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
297	297	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
298	298	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
299	299	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
300	300	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
301	301	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
302	302	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
303	303	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
304	304	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
305	305	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
306	306	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
307	307	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
308	308	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
309	309	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
310	310	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
311	311	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
312	312	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
313	313	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
314	314	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
315	315	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
316	316	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
317	317	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
318	318	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
319	319	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
320	320	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
321	321	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
322	322	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
323	323	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
324	324	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
325	325	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
326	326	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
327	327	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
328	328	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
329	329	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
330	330	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
331	331	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
332	332	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
333	333	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
334	334	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
335	335	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
336	336	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
337	337	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
338	338	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
339	339	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
340	340	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
341	341	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
342	342	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
343	343	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
344	344	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
345	345	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
346	346	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
347	347	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
348	348	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
349	349	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
350	350	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
351	351	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
352	352	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
353	353	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
354	354	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
355	355	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
356	356	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
357	357	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
358	358	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
359	359	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
360	360	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
361	361	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
362	362	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
363	363	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
364	364	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
365	365	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
366	366	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
367	367	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
368	368	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
369	369	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
370	370	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
371	371	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
372	372	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
373	373	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
374	374	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
375	375	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
376	376	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
377	377	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
378	378	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
379	379	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
380	380	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
381	381	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
382	382	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
383	383	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
384	384	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
385	385	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
386	386	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
387	387	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
388	388	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
389	389	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
390	390	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
391	391	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
392	392	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
393	393	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
394	394	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
395	395	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
396	396	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
397	397	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
398	398	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
399	399	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
400	400	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
401	401	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
402	402	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
403	403	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
404	404	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
405	405	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
406	406	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
407	407	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
408	408	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
409	409	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
410	410	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
411	411	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
412	412	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
413	413	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
414	414	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
415	415	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
416	416	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
417	417	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
418	418	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
419	419	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
420	420	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
421	421	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
422	422	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
423	423	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
424	424	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
425	425	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
426	426	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
427	427	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
428	428	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
429	429	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
430	430	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
431	431	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
432	432	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
433	433	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
434	434	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
435	435	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
436	436	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
437	437	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
438	438	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
439	439	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
440	440	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
441	441	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
442	442	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
443	443	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
444	444	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
445	445	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
446	446	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
447	447	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
448	448	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
449	449	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
450	450	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
451	451	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
452	452	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
453	453	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
454	454	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
455	455	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
456	456	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
457	457	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
458	458	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
459	459	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
460	460	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
461	461	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
462	462	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
463	463	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
464	464	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
465	465	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
466	466	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
467	467	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
468	468	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
469	469	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
470	470	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
471	471	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
472	472	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
473	473	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
474	474	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
475	475	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
476	476	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
477	477	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
478	478	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
479	479	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
480	480	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
481	481	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
482	482	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
483	483	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
484	484	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
485	485	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
486	486	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
487	487	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
488	488	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
489	489	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
490	490	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
491	491	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
492	492	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
493	493	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
494	494	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
495	495	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
496	496	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
497	497	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
498	498	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
499	499	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
500	500	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
501	501	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
502	502	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
503	503	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
504	504	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
505	505	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
506	506	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
507	507	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
508	508	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
509	509	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
510	510	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
511	511	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
512	512	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
513	513	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
514	514	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
515	515	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
516	516	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
517	517	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
518	518	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
519	519	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
520	520	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
521	521	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
522	522	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
523	523	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
524	524	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
525	525	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
526	526	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
527	527	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
528	528	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
529	529	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
530	530	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
531	531	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
532	532	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
533	533	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
534	534	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
535	535	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
536	536	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
537	537	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
538	538	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
539	539	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
540	540	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
541	541	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
542	542	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
543	543	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
544	544	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
545	545	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
546	546	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
547	547	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
548	548	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
549	549	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
550	550	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
551	551	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
552	552	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
553	553	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
554	554	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
555	555	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
556	556	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
557	557	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
558	558	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
559	559	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
560	560	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
561	561	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
562	562	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
563	563	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
564	564	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
565	565	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
566	566	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
567	567	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
568	568	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
569	569	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
570	570	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
571	571	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
572	572	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
573	573	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
574	574	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
575	575	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
576	576	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
577	577	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
578	578	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
579	579	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
580	580	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
581	581	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
582	582	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
583	583	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
584	584	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
585	585	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
586	586	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
587	587	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
588	588	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
589	589	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
590	590	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
591	591	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
592	592	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
593	593	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
594	594	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
595	595	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
596	596	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
597	597	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
598	598	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
599	599	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
600	600	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
601	601	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
602	602	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
603	603	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
604	604	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
605	605	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
606	606	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
607	607	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
608	608	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
609	609	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
610	610	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
611	611	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
612	612	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
613	613	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
614	614	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
615	615	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
616	616	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
617	617	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
618	618	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
619	619	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
620	620	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
621	621	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
622	622	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
623	623	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
624	624	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
625	625	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
626	626	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
627	627	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
628	628	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
629	629	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
630	630	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
631	631	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
632	632	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
633	633	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
634	634	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
635	635	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
636	636	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
637	637	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
638	638	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
639	639	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
640	640	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
641	641	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
642	642	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
643	643	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
644	644	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
645	645	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
646	646	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
647	647	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
648	648	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
649	649	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
650	650	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
651	651	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
652	652	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
653	653	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
654	654	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
655	655	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
656	656	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
657	657	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
658	658	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
659	659	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
660	660	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
661	661	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
662	662	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
663	663	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
664	664	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
665	665	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
666	666	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
667	667	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
668	668	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
669	669	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
670	670	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
671	671	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
672	672	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
673	673	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
674	674	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
675	675	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
676	676	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
677	677	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
678	678	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
679	679	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
680	680	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
681	681	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
682	682	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
683	683	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
684	684	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
685	685	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
686	686	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
687	687	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
688	688	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
689	689	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
690	690	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
691	691	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
692	692	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
693	693	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
694	694	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
695	695	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
696	696	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
697	697	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
698	698	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
699	699	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
700	700	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
701	701	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
702	702	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
703	703	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
704	704	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
705	705	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
706	706	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
707	707	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
708	708	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
709	709	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
710	710	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
711	711	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
712	712	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
713	713	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
714	714	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
715	715	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
716	716	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
717	717	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
718	718	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
719	719	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
720	720	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
721	721	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
722	722	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
723	723	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
724	724	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
725	725	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
726	726	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
727	727	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
728	728	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
729	729	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
730	730	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
731	731	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
732	732	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
733	733	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
734	734	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
735	735	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
736	736	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
737	737	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
738	738	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
739	739	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
740	740	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
741	741	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
742	742	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
743	743	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
744	744	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
745	745	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
746	746	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
747	747	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
748	748	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
749	749	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
750	750	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
751	751	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
752	752	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
753	753	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
754	754	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
755	755	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
756	756	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
757	757	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
758	758	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
759	759	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
760	760	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
761	761	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
762	762	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
763	763	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
764	764	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
765	765	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
766	766	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
767	767	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
768	768	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
769	769	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
770	770	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
771	771	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
772	772	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
773	773	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
774	774	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
775	775	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
776	776	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
777	777	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
778	778	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
779	779	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
780	780	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
781	781	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
782	782	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
783	783	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
784	784	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
785	785	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
786	786	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
787	787	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
788	788	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
789	789	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
790	790	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
791	791	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
792	792	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
793	793	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
794	794	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
795	795	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
796	796	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
797	797	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
798	798	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
799	799	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
800	800	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
801	801	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
802	802	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
803	803	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
804	804	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
805	805	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
806	806	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
807	807	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
808	808	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
809	809	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
810	810	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
811	811	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
812	812	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
813	813	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
814	814	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
815	815	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
816	816	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
817	817	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
818	818	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
819	819	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
820	820	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
821	821	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
822	822	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
823	823	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
824	824	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
825	825	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
826	826	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
827	827	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
828	828	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
829	829	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
830	830	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
831	831	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
832	832	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
833	833	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
834	834	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
835	835	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
836	836	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
837	837	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
838	838	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
839	839	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
840	840	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
841	841	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
842	842	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
843	843	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
844	844	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
845	845	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
846	846	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
847	847	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
848	848	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
849	849	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
850	850	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
851	851	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
852	852	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
853	853	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
854	854	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
855	855	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
856	856	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
857	857	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
858	858	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
859	859	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
860	860	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
861	861	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
862	862	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
863	863	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
864	864	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
865	865	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
866	866	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
867	867	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
868	868	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
869	869	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
870	870	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
871	871	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
872	872	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
873	873	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
874	874	\N	10	\N	\N	t	t	2026-09-03 19:26:39.118128
875	875	\N	9	\N	\N	t	t	2026-09-03 19:26:39.118128
876	876	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
877	877	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
878	878	\N	11	\N	\N	t	t	2026-09-03 19:26:39.118128
879	879	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
880	880	\N	3	\N	\N	t	t	2026-09-03 19:26:39.118128
881	881	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
882	882	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
883	883	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
884	884	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
885	885	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
886	886	\N	2	\N	\N	t	t	2026-09-03 19:26:39.118128
887	887	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
888	888	\N	8	\N	\N	t	t	2026-09-03 19:26:39.118128
889	889	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
890	890	\N	12	\N	\N	t	t	2026-09-03 19:26:39.118128
891	891	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
892	892	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
893	893	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
894	894	\N	5	\N	\N	t	t	2026-09-03 19:26:39.118128
895	895	\N	6	\N	\N	t	t	2026-09-03 19:26:39.118128
896	896	\N	7	\N	\N	t	t	2026-09-03 19:26:39.118128
897	897	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
898	898	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
899	899	\N	4	\N	\N	t	t	2026-09-03 19:26:39.118128
900	900	\N	1	\N	\N	t	t	2026-09-03 19:26:39.118128
\.


--
-- Data for Name: model_versions; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.model_versions (model_version_id, model_type, version_name, model_path, dataset_version, accuracy, precision_score, recall_score, f1_score, trained_at, deployed_at, is_active) FROM stdin;
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
1	vet_sharma	vet
2	vet_patel	vet
3	lab_tech1	lab_tech
\.


--
-- Data for Name: vaccination_records; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.vaccination_records (vaccination_id, farmer_id, animal_tag_id, animal_species, disease_protected_id, vaccine_name, vaccinated_on, next_due_date, administered_by, is_current, created_at) FROM stdin;
\.


--
-- Data for Name: vet_verifications; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.vet_verifications (verification_id, report_id, vet_id, confirmed_disease_id, is_confirmed, clinical_notes, internal_hemorrhage, used_in_training, verified_at) FROM stdin;
1	43	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
2	100	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
3	545	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
4	653	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
5	363	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
6	865	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
7	443	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
8	626	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
9	668	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
10	879	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
11	280	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
12	344	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
13	277	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
14	274	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
15	822	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
16	101	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
17	262	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
18	671	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
19	599	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
20	401	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
21	473	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
22	792	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
23	692	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
24	768	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
25	248	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
26	752	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
27	689	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
28	603	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
29	789	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
30	200	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
31	533	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
32	346	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
33	694	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
34	707	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
35	185	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
36	321	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
37	561	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
38	11	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
39	874	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
40	9	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
41	852	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
42	70	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
43	13	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
44	422	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
45	885	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
46	538	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
47	107	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
48	702	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
49	457	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
50	360	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
51	225	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
52	743	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
53	291	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
54	258	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
55	198	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
56	35	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
57	25	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
58	635	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
59	95	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
60	59	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
61	609	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
62	673	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
63	223	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
64	614	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
65	654	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
66	125	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
67	726	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
68	123	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
69	89	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
70	620	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
71	134	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
72	385	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
73	839	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
74	783	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
75	664	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
76	580	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
77	823	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
78	190	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
79	114	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
80	713	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
81	189	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
82	260	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
83	302	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
84	479	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
85	677	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
86	78	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
87	655	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
88	465	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
89	284	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
90	788	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
91	438	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
92	709	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
93	684	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
94	872	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
95	807	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
96	332	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
97	264	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
98	166	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
99	800	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
100	76	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
101	812	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
102	796	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
103	64	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
104	392	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
105	398	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
106	341	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
107	62	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
108	265	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
109	272	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
110	183	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
111	452	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
112	72	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
113	504	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
114	206	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
115	625	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
116	403	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
117	791	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
118	661	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
119	811	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
120	112	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
121	148	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
122	554	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
123	442	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
124	224	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
125	629	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
126	659	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
127	109	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
128	453	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
129	733	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
130	266	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
131	106	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
132	36	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
133	75	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
134	73	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
135	586	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
136	746	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
137	257	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
138	860	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
139	20	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
140	510	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
141	153	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
142	669	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
143	656	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
144	1	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
145	39	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
146	681	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
147	400	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
148	273	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
149	156	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
150	717	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
151	338	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
152	881	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
153	589	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
154	4	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
155	528	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
156	725	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
157	503	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
158	490	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
159	447	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
160	414	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
161	806	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
162	779	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
163	232	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
164	747	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
165	394	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
166	706	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
167	494	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
168	835	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
169	581	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
170	549	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
171	368	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
172	342	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
173	699	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
174	311	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
175	411	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
176	57	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
177	648	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
178	663	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
179	93	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
180	375	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
181	548	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
182	349	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
183	83	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
184	471	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
185	297	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
186	826	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
187	208	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
188	181	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
189	568	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
190	41	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
191	736	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
192	816	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
193	196	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
194	307	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
195	754	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
196	110	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
197	646	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
198	730	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
199	499	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
200	87	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
201	724	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
202	449	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
203	195	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
204	144	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
205	37	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
206	846	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
207	26	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
208	608	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
209	245	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
210	501	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
211	399	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
212	65	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
213	739	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
214	775	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
215	316	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
216	512	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
217	547	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
218	461	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
219	17	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
220	38	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
221	348	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
222	58	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
223	869	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
224	44	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
225	416	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
226	122	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
227	217	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
228	670	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
229	536	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
230	470	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
231	550	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
232	760	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
233	594	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
234	239	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
235	74	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
236	755	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
237	145	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
238	691	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
239	762	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
240	483	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
241	634	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
242	47	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
243	249	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
244	830	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
245	15	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
246	177	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
247	700	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
248	52	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
249	315	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
250	899	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
251	468	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
252	893	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
253	175	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
254	606	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
255	66	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
256	774	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
257	117	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
258	761	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
259	610	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
260	631	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
261	226	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
262	862	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
263	714	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
264	437	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
265	678	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
266	412	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
267	333	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
268	124	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
269	590	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
270	559	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
271	141	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
272	330	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
273	219	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
274	687	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
275	693	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
276	178	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
277	889	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
278	639	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
279	633	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
280	281	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
281	715	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
282	426	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
283	173	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
284	379	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
285	567	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
286	169	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
287	450	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
288	250	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
289	596	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
290	42	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
291	137	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
292	103	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
293	386	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
294	162	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
295	682	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
296	853	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
297	718	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
298	7	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
299	8	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
300	184	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
301	92	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
302	848	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
303	427	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
304	488	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
305	130	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
306	212	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
307	147	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
308	278	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
309	672	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
310	462	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
311	857	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
312	878	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
313	179	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
314	756	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
315	866	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
316	685	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
317	91	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
318	309	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
319	357	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
320	429	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
321	5	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
322	572	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
323	242	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
324	197	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
325	121	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
326	543	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
327	98	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
328	371	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
329	553	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
330	520	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
331	850	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
332	476	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
333	214	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
334	802	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
335	55	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
336	199	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
337	116	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
338	759	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
339	486	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
340	643	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
341	821	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
342	164	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
343	45	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
344	56	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
345	373	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
346	292	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
347	215	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
348	446	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
349	847	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
350	343	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
351	813	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
352	558	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
353	854	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
354	54	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
355	560	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
356	607	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
357	30	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
358	497	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
359	765	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
360	119	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
361	767	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
362	241	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
363	456	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
364	334	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
365	430	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
366	204	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
367	537	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
368	236	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
369	113	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
370	534	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
371	234	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
372	856	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
373	243	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
374	423	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
375	205	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
376	829	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
377	640	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
378	801	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
379	827	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
380	575	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
381	557	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
382	742	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
383	149	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
384	222	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
385	466	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
386	784	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
387	397	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
388	383	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
389	140	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
390	235	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
391	369	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
392	651	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
393	324	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
394	601	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
395	500	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
396	139	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
397	104	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
398	172	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
399	704	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
400	647	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
401	355	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
402	555	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
403	31	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
404	697	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
405	859	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
406	745	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
407	637	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
408	667	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
409	511	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
410	688	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
411	88	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
412	390	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
413	176	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
414	532	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
415	454	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
416	152	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
417	310	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
418	81	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
419	405	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
420	407	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
421	327	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
422	314	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
423	464	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
424	849	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
425	296	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
426	616	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
427	810	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
428	118	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
429	731	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
430	211	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
431	439	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
432	268	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
433	251	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
434	778	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
435	111	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
436	303	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
437	542	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
438	732	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
439	237	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
440	143	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
441	602	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
442	374	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
443	220	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
444	377	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
445	519	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
446	127	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
447	455	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
448	168	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
449	838	1	12	t	\N	\N	t	2026-09-03 19:26:39.118128
450	716	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
451	886	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
452	828	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
453	77	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
454	294	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
455	3	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
456	712	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
457	23	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
458	21	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
459	539	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
460	376	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
461	710	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
462	259	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
463	18	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
464	218	1	6	t	\N	\N	t	2026-09-03 19:26:39.118128
465	891	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
466	202	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
467	246	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
468	415	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
469	409	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
470	582	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
471	421	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
472	51	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
473	738	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
474	254	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
475	622	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
476	900	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
477	286	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
478	649	1	11	t	\N	\N	t	2026-09-03 19:26:39.118128
479	873	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
480	506	2	12	t	\N	\N	t	2026-09-03 19:26:39.118128
481	721	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
482	209	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
483	781	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
484	68	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
485	507	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
486	485	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
487	833	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
488	805	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
489	627	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
490	861	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
491	434	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
492	551	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
493	157	1	9	t	\N	\N	t	2026-09-03 19:26:39.118128
494	604	2	11	t	\N	\N	t	2026-09-03 19:26:39.118128
495	361	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
496	870	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
497	293	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
498	513	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
499	299	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
500	858	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
501	233	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
502	238	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
503	396	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
504	71	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
505	406	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
506	638	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
507	842	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
508	824	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
509	895	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
510	690	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
511	799	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
512	325	1	7	t	\N	\N	t	2026-09-03 19:26:39.118128
513	757	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
514	322	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
515	696	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
516	695	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
517	354	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
518	171	2	4	t	\N	\N	t	2026-09-03 19:26:39.118128
519	436	1	5	t	\N	\N	t	2026-09-03 19:26:39.118128
520	723	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
521	433	2	10	t	\N	\N	t	2026-09-03 19:26:39.118128
522	628	2	1	t	\N	\N	t	2026-09-03 19:26:39.118128
523	505	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
524	358	2	8	t	\N	\N	t	2026-09-03 19:26:39.118128
525	817	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
526	593	1	8	t	\N	\N	t	2026-09-03 19:26:39.118128
527	295	2	5	t	\N	\N	t	2026-09-03 19:26:39.118128
528	720	2	2	t	\N	\N	t	2026-09-03 19:26:39.118128
529	351	1	1	t	\N	\N	t	2026-09-03 19:26:39.118128
530	611	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
531	318	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
532	744	1	2	t	\N	\N	t	2026-09-03 19:26:39.118128
533	29	1	4	t	\N	\N	t	2026-09-03 19:26:39.118128
534	804	1	3	t	\N	\N	t	2026-09-03 19:26:39.118128
535	636	2	9	t	\N	\N	t	2026-09-03 19:26:39.118128
536	187	2	6	t	\N	\N	t	2026-09-03 19:26:39.118128
537	27	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
538	495	2	3	t	\N	\N	t	2026-09-03 19:26:39.118128
539	577	2	7	t	\N	\N	t	2026-09-03 19:26:39.118128
540	188	1	10	t	\N	\N	t	2026-09-03 19:26:39.118128
\.


--
-- Name: diseases_disease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.diseases_disease_id_seq', 12, true);


--
-- Name: field_reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.field_reports_report_id_seq', 900, true);


--
-- Name: lab_reports_lab_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.lab_reports_lab_report_id_seq', 900, true);


--
-- Name: model_versions_model_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.model_versions_model_version_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.triage_results_triage_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.users_user_id_seq', 3, true);


--
-- Name: vaccination_records_vaccination_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.vaccination_records_vaccination_id_seq', 1, false);


--
-- Name: vet_verifications_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.vet_verifications_verification_id_seq', 540, true);


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
-- Name: vaccination_records vaccination_records_pkey; Type: CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vaccination_records
    ADD CONSTRAINT vaccination_records_pkey PRIMARY KEY (vaccination_id);


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
-- Name: vaccination_records vaccination_records_disease_protected_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vaccination_records
    ADD CONSTRAINT vaccination_records_disease_protected_id_fkey FOREIGN KEY (disease_protected_id) REFERENCES public.diseases(disease_id);


--
-- Name: vaccination_records vaccination_records_farmer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parag
--

ALTER TABLE ONLY public.vaccination_records
    ADD CONSTRAINT vaccination_records_farmer_id_fkey FOREIGN KEY (farmer_id) REFERENCES public.users(user_id);


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

\unrestrict shp8sXgBWm74caN3JaUlIu8FKahe7KwhI6AJFZuoAjuWVlbqnElcdZi84Nieote

