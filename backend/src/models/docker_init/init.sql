--
-- PostgreSQL database dump
--

\restrict U1mf5fzAuxYzhD1y77XIXeZesK7QrRxGawjYOcfiUzcMgjaYD6JaR8PU9gK6c0z

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
457	431	\N	s3://livestock-images-prod/mock_image_1.jpg	{43,45}	-8.316236	71.338899	2026-09-02 22:21:58.317959
458	327	Chickens	s3://livestock-images-prod/mock_image_2.jpg	{12,16,17,12,15,20}	58.776918	10.619800	2026-09-02 22:21:58.317959
459	404	\N	s3://livestock-images-prod/mock_image_3.jpg	{1,3,4,5,6,9,10,11}	66.618270	-172.088591	2026-09-02 22:21:58.317959
460	481	\N	s3://livestock-images-prod/mock_image_4.jpg	{4,69,30}	-4.761500	-116.725854	2026-09-02 22:21:58.317959
461	246	Cattle	s3://livestock-images-prod/mock_image_5.jpg	{23,24,26}	-45.168881	59.937562	2026-09-02 22:21:58.317959
462	426	\N	s3://livestock-images-prod/mock_image_6.jpg	{57,58}	-17.151662	161.988777	2026-09-02 22:21:58.317959
463	91	Cattle	s3://livestock-images-prod/mock_image_7.jpg	{23,24,26}	-16.337927	134.754620	2026-09-02 22:21:58.317959
464	181	Cattle	s3://livestock-images-prod/mock_image_8.jpg	{23,24,25,26}	36.726267	-83.620236	2026-09-02 22:21:58.317959
465	252	Cattle	s3://livestock-images-prod/mock_image_9.jpg	{23,24,25}	22.668458	93.464466	2026-09-02 22:21:58.317959
466	105	Cattle	s3://livestock-images-prod/mock_image_10.jpg	{26}	79.854757	121.876026	2026-09-02 22:21:58.317959
467	7	Cattle	s3://livestock-images-prod/mock_image_11.jpg	{23,24}	60.999193	110.272684	2026-09-02 22:21:58.317959
468	471	\N	s3://livestock-images-prod/mock_image_12.jpg	{69}	-51.138304	-121.543006	2026-09-02 22:21:58.317959
469	203	Pigs	s3://livestock-images-prod/mock_image_13.jpg	{53,54}	-85.120846	-106.294479	2026-09-02 22:21:58.317959
470	412	Cattle	s3://livestock-images-prod/mock_image_14.jpg	{23,24,25,26}	70.403075	59.144562	2026-09-02 22:21:58.317959
471	317	Cattle	s3://livestock-images-prod/mock_image_15.jpg	{35,47,62,63,66,67}	30.538554	55.300734	2026-09-02 22:21:58.317959
472	474	\N	s3://livestock-images-prod/mock_image_16.jpg	{1,3,5,6,7,8,9,10}	37.511301	25.457031	2026-09-02 22:21:58.317959
473	90	\N	s3://livestock-images-prod/mock_image_17.jpg	{69}	-12.418053	-40.058265	2026-09-02 22:21:58.317959
474	240	\N	s3://livestock-images-prod/mock_image_18.jpg	{36,37,38,39,40,41,42}	-56.251744	96.875707	2026-09-02 22:21:58.317959
475	339	Chickens	s3://livestock-images-prod/mock_image_19.jpg	{12,16,12,6,15,18,19,21}	-89.922698	2.737266	2026-09-02 22:21:58.317959
476	26	Cattle	s3://livestock-images-prod/mock_image_20.jpg	{35,47,62,63,64,65}	51.556725	170.489390	2026-09-02 22:21:58.317959
477	67	Turkeys	s3://livestock-images-prod/mock_image_21.jpg	{12,17,12,6,15,20,21,22}	83.316203	-103.859921	2026-09-02 22:21:58.317959
478	156	Chickens	s3://livestock-images-prod/mock_image_22.jpg	{12,16,17,12,6,15,20}	33.916866	-11.957732	2026-09-02 22:21:58.317959
479	70	\N	s3://livestock-images-prod/mock_image_23.jpg	{36,37,39,41,42}	-79.632089	-40.261810	2026-09-02 22:21:58.317959
480	30	\N	s3://livestock-images-prod/mock_image_24.jpg	{1,27,29,32,33,34}	57.359033	127.372916	2026-09-02 22:21:58.317959
481	499	\N	s3://livestock-images-prod/mock_image_25.jpg	{2,3,5,6,7,9,10,11}	-6.956088	168.347277	2026-09-02 22:21:58.317959
482	443	\N	s3://livestock-images-prod/mock_image_26.jpg	{27,28,29,30,32}	66.586027	-34.785038	2026-09-02 22:21:58.317959
483	144	Pigs	s3://livestock-images-prod/mock_image_27.jpg	{54,55}	37.309605	-99.565047	2026-09-02 22:21:58.317959
484	381	Pigs	s3://livestock-images-prod/mock_image_28.jpg	{35,54,55}	5.522438	-87.109668	2026-09-02 22:21:58.317959
485	332	\N	s3://livestock-images-prod/mock_image_29.jpg	{2,43,46}	-8.403182	98.875810	2026-09-02 22:21:58.317959
486	71	Cattle	s3://livestock-images-prod/mock_image_30.jpg	{23,24,26}	12.401633	-162.817845	2026-09-02 22:21:58.317959
487	166	Chickens	s3://livestock-images-prod/mock_image_31.jpg	{16,12,15,19,20,21,22}	71.924632	-85.912863	2026-09-02 22:21:58.317959
488	268	\N	s3://livestock-images-prod/mock_image_32.jpg	{2,57,58,60}	17.077667	-11.918581	2026-09-02 22:21:58.317959
489	452	Cattle	s3://livestock-images-prod/mock_image_33.jpg	{47,62,66,67}	51.509748	-1.123992	2026-09-02 22:21:58.317959
490	225	\N	s3://livestock-images-prod/mock_image_34.jpg	{2,43,45}	-0.429628	99.192353	2026-09-02 22:21:58.317959
491	168	\N	s3://livestock-images-prod/mock_image_35.jpg	{57,58,61}	59.174433	2.093884	2026-09-02 22:21:58.317959
492	345	\N	s3://livestock-images-prod/mock_image_36.jpg	{2,45}	52.200512	-98.401738	2026-09-02 22:21:58.317959
493	135	Turkeys	s3://livestock-images-prod/mock_image_37.jpg	{12,16,17,12,6,15,19,20,21}	32.625802	158.634571	2026-09-02 22:21:58.317959
494	237	Sheep	s3://livestock-images-prod/mock_image_38.jpg	{12,12,13,14}	-32.137546	-93.382017	2026-09-02 22:21:58.317959
495	82	Cattle	s3://livestock-images-prod/mock_image_39.jpg	{23,24,25}	48.264155	56.319382	2026-09-02 22:21:58.317959
496	245	\N	s3://livestock-images-prod/mock_image_40.jpg	{1,3,4,6,7,8,11,22}	11.373891	111.654229	2026-09-02 22:21:58.317959
497	267	\N	s3://livestock-images-prod/mock_image_41.jpg	{1,2,3,4,5,7,8}	-71.671762	136.780494	2026-09-02 22:21:58.317959
498	21	Pigs	s3://livestock-images-prod/mock_image_42.jpg	{53,55}	73.805751	-179.920278	2026-09-02 22:21:58.317959
499	58	Cattle	s3://livestock-images-prod/mock_image_43.jpg	{23,26}	24.561673	-80.227100	2026-09-02 22:21:58.317959
500	151	\N	s3://livestock-images-prod/mock_image_44.jpg	{1,27,28,29,32,33}	-43.402770	74.507775	2026-09-02 22:21:58.317959
501	440	\N	s3://livestock-images-prod/mock_image_45.jpg	{1,27,29,34}	40.776182	-139.211191	2026-09-02 22:21:58.317959
502	417	\N	s3://livestock-images-prod/mock_image_46.jpg	{1,3,4,5,6,9}	-56.148690	-156.560983	2026-09-02 22:21:58.317959
503	55	Turkeys	s3://livestock-images-prod/mock_image_47.jpg	{12,16,17,12,6,15,19,21,22}	61.328092	-3.754025	2026-09-02 22:21:58.317959
504	204	\N	s3://livestock-images-prod/mock_image_48.jpg	{69}	-81.771032	164.490001	2026-09-02 22:21:58.317959
505	97	Cattle	s3://livestock-images-prod/mock_image_49.jpg	{47,62,63,64,65,68}	83.234994	-82.650094	2026-09-02 22:21:58.317959
506	109	\N	s3://livestock-images-prod/mock_image_50.jpg	{35,39,41,42}	34.203934	-62.132649	2026-09-02 22:21:58.317959
507	428	\N	s3://livestock-images-prod/mock_image_51.jpg	{56,57,58,59,60}	52.551243	-136.590685	2026-09-02 22:21:58.317959
508	194	\N	s3://livestock-images-prod/mock_image_52.jpg	{1,27,29,30}	-79.449418	-116.800185	2026-09-02 22:21:58.317959
509	206	Sheep	s3://livestock-images-prod/mock_image_53.jpg	{12,12,13,14}	-54.401124	39.179053	2026-09-02 22:21:58.317959
510	112	\N	s3://livestock-images-prod/mock_image_54.jpg	{56,57,58}	-3.376516	-16.048963	2026-09-02 22:21:58.317959
511	22	\N	s3://livestock-images-prod/mock_image_55.jpg	{1,2,4,5,6,10,11}	36.655457	-160.787647	2026-09-02 22:21:58.317959
512	409	\N	s3://livestock-images-prod/mock_image_56.jpg	{1,27,28,29,30,31,33}	-27.496205	165.174907	2026-09-02 22:21:58.317959
513	443	\N	s3://livestock-images-prod/mock_image_57.jpg	{36,37,38,40,42}	-48.449377	69.272643	2026-09-02 22:21:58.317959
514	199	\N	s3://livestock-images-prod/mock_image_58.jpg	{1,27,28,29,31,34}	-74.815886	-22.785392	2026-09-02 22:21:58.317959
515	324	Cattle	s3://livestock-images-prod/mock_image_59.jpg	{35,47,62,63,65,66,67}	-35.397414	-63.353775	2026-09-02 22:21:58.317959
516	464	\N	s3://livestock-images-prod/mock_image_60.jpg	{1,27,28,29,32,33}	14.808757	-84.208395	2026-09-02 22:21:58.317959
517	161	Cattle	s3://livestock-images-prod/mock_image_61.jpg	{35,62,68}	-38.546013	-35.684833	2026-09-02 22:21:58.317959
518	278	\N	s3://livestock-images-prod/mock_image_62.jpg	{27,28,29,30,32,33}	16.958319	150.030468	2026-09-02 22:21:58.317959
519	380	Cattle	s3://livestock-images-prod/mock_image_63.jpg	{23,24,25,26}	-68.479714	-0.124994	2026-09-02 22:21:58.317959
520	246	Cattle	s3://livestock-images-prod/mock_image_64.jpg	{35,62,63,64,65,67}	69.639203	87.276273	2026-09-02 22:21:58.317959
521	210	Sheep	s3://livestock-images-prod/mock_image_65.jpg	{12,12,13,14}	-67.314625	-115.974362	2026-09-02 22:21:58.317959
522	275	\N	s3://livestock-images-prod/mock_image_66.jpg	{4,69}	-33.084711	-63.478767	2026-09-02 22:21:58.317959
523	279	\N	s3://livestock-images-prod/mock_image_67.jpg	{56,58,59}	6.501208	-142.845284	2026-09-02 22:21:58.317959
524	35	\N	s3://livestock-images-prod/mock_image_68.jpg	{4,35,37,39,40,41,42}	-68.461854	18.072844	2026-09-02 22:21:58.317959
525	402	Cattle	s3://livestock-images-prod/mock_image_69.jpg	{47,27,35,48,49,50,51}	49.113329	167.799476	2026-09-02 22:21:58.317959
526	221	\N	s3://livestock-images-prod/mock_image_70.jpg	{1,2,3,4,6,7,11}	14.238113	-10.610099	2026-09-02 22:21:58.317959
527	117	\N	s3://livestock-images-prod/mock_image_71.jpg	{27,29,32,33,34}	1.738446	-58.169393	2026-09-02 22:21:58.317959
528	316	Chickens	s3://livestock-images-prod/mock_image_72.jpg	{12,15,22}	35.359581	144.956280	2026-09-02 22:21:58.317959
529	367	Cattle	s3://livestock-images-prod/mock_image_73.jpg	{23,24,25,26}	-3.229942	-13.043314	2026-09-02 22:21:58.317959
530	314	\N	s3://livestock-images-prod/mock_image_74.jpg	{69}	7.546842	173.002908	2026-09-02 22:21:58.317959
531	123	Cattle	s3://livestock-images-prod/mock_image_75.jpg	{23,24,25,26}	-23.264705	148.396754	2026-09-02 22:21:58.317959
532	374	\N	s3://livestock-images-prod/mock_image_76.jpg	{1,29,30,31,32,34}	-48.490035	-49.843486	2026-09-02 22:21:58.317959
533	61	Pigs	s3://livestock-images-prod/mock_image_77.jpg	{35,53,54,55}	46.615323	-19.430900	2026-09-02 22:21:58.317959
534	178	Cattle	s3://livestock-images-prod/mock_image_78.jpg	{47,62,63,64,68}	-41.954653	139.887973	2026-09-02 22:21:58.317959
535	264	Cattle	s3://livestock-images-prod/mock_image_79.jpg	{35,47,62,63,64,66,67,68}	-66.142941	-136.225687	2026-09-02 22:21:58.317959
536	195	Chickens	s3://livestock-images-prod/mock_image_80.jpg	{12,16,17,12,6,15,18,20,21}	16.162892	93.787992	2026-09-02 22:21:58.317959
537	77	\N	s3://livestock-images-prod/mock_image_81.jpg	{56,58}	-32.272610	147.417208	2026-09-02 22:21:58.317959
538	70	Pigs	s3://livestock-images-prod/mock_image_82.jpg	{54,20}	-7.579194	-108.537376	2026-09-02 22:21:58.317959
539	237	Cattle	s3://livestock-images-prod/mock_image_83.jpg	{12,12,13,14}	-67.134321	67.619647	2026-09-02 22:21:58.317959
540	248	\N	s3://livestock-images-prod/mock_image_84.jpg	{4,69}	15.391843	-138.074362	2026-09-02 22:21:58.317959
541	382	\N	s3://livestock-images-prod/mock_image_85.jpg	{4,35,36,37,38,39,40,42,5}	-27.621080	-75.048369	2026-09-02 22:21:58.317959
542	445	\N	s3://livestock-images-prod/mock_image_86.jpg	{69}	89.401047	-64.986101	2026-09-02 22:21:58.317959
543	390	\N	s3://livestock-images-prod/mock_image_87.jpg	{3,4,6,7,9}	-12.628017	-82.792515	2026-09-02 22:21:58.317959
544	340	Cattle	s3://livestock-images-prod/mock_image_88.jpg	{23,24,25,26}	4.088821	160.854333	2026-09-02 22:21:58.317959
545	126	\N	s3://livestock-images-prod/mock_image_89.jpg	{35,36,40,41,42}	-26.285978	173.873000	2026-09-02 22:21:58.317959
546	90	\N	s3://livestock-images-prod/mock_image_90.jpg	{2,43,45}	18.865850	-73.948110	2026-09-02 22:21:58.317959
547	132	\N	s3://livestock-images-prod/mock_image_91.jpg	{2,56,57,58,59}	-88.780398	71.568644	2026-09-02 22:21:58.317959
548	207	\N	s3://livestock-images-prod/mock_image_92.jpg	{36,39,41,42}	-49.224755	-6.775278	2026-09-02 22:21:58.317959
549	415	\N	s3://livestock-images-prod/mock_image_93.jpg	{1,2,4,7,8,9}	-65.303946	111.269315	2026-09-02 22:21:58.317959
550	436	\N	s3://livestock-images-prod/mock_image_94.jpg	{1,3,4,6,7,8,9,10,11,20}	83.147821	-83.500052	2026-09-02 22:21:58.317959
551	333	Cattle	s3://livestock-images-prod/mock_image_95.jpg	{23,24,25,26}	-80.544295	30.490695	2026-09-02 22:21:58.317959
552	448	Sheep	s3://livestock-images-prod/mock_image_96.jpg	{12,12,13,14}	-68.809338	176.943663	2026-09-02 22:21:58.317959
553	127	Cattle	s3://livestock-images-prod/mock_image_97.jpg	{62,67,68}	-32.117858	28.632213	2026-09-02 22:21:58.317959
554	323	Goats	s3://livestock-images-prod/mock_image_98.jpg	{47,52,30,35,48,49,51}	62.963382	97.248606	2026-09-02 22:21:58.317959
555	268	Chickens	s3://livestock-images-prod/mock_image_99.jpg	{12,16,17,12,15,19,22}	-57.244246	174.643983	2026-09-02 22:21:58.317959
556	68	Pigs	s3://livestock-images-prod/mock_image_100.jpg	{53,54}	84.385594	6.979675	2026-09-02 22:21:58.317959
557	437	Cattle	s3://livestock-images-prod/mock_image_101.jpg	{35,62,63,64,66,67,49}	30.751870	11.522300	2026-09-02 22:21:58.317959
558	104	Pigs	s3://livestock-images-prod/mock_image_102.jpg	{35,54,55}	67.917857	-143.155598	2026-09-02 22:21:58.317959
559	226	\N	s3://livestock-images-prod/mock_image_103.jpg	{1,27,28,29,30,31,32,34,22}	4.840223	-23.717293	2026-09-02 22:21:58.317959
560	354	Pigs	s3://livestock-images-prod/mock_image_104.jpg	{47,27,27,52,35,48,49}	81.955935	116.230751	2026-09-02 22:21:58.317959
561	273	\N	s3://livestock-images-prod/mock_image_105.jpg	{1,28,29,34}	-41.001742	0.047182	2026-09-02 22:21:58.317959
562	231	\N	s3://livestock-images-prod/mock_image_106.jpg	{2,56,58,59,60,61}	-43.476309	96.413723	2026-09-02 22:21:58.317959
563	339	Pigs	s3://livestock-images-prod/mock_image_107.jpg	{54}	-84.842760	-131.563739	2026-09-02 22:21:58.317959
564	208	Pigs	s3://livestock-images-prod/mock_image_108.jpg	{54,55}	-44.878762	-97.423121	2026-09-02 22:21:58.317959
565	307	\N	s3://livestock-images-prod/mock_image_109.jpg	{43,45,46}	65.433471	134.855473	2026-09-02 22:21:58.317959
566	348	\N	s3://livestock-images-prod/mock_image_110.jpg	{1,27,28,29}	-61.380650	-120.890315	2026-09-02 22:21:58.317959
567	150	Cattle	s3://livestock-images-prod/mock_image_111.jpg	{24,25,26}	-25.496252	-5.552183	2026-09-02 22:21:58.317959
568	77	Pigs	s3://livestock-images-prod/mock_image_112.jpg	{53,54,55}	84.695978	46.888394	2026-09-02 22:21:58.317959
569	383	\N	s3://livestock-images-prod/mock_image_113.jpg	{35,36,37,39,42}	43.041441	101.702430	2026-09-02 22:21:58.317959
570	402	\N	s3://livestock-images-prod/mock_image_114.jpg	{36,37,39,40,42}	31.502830	106.019892	2026-09-02 22:21:58.317959
571	465	Goats	s3://livestock-images-prod/mock_image_115.jpg	{47,27,27,52,30,48,49,50,51}	-39.109662	176.579265	2026-09-02 22:21:58.317959
572	496	Cattle	s3://livestock-images-prod/mock_image_116.jpg	{23,25,26}	82.353039	139.009190	2026-09-02 22:21:58.317959
573	50	\N	s3://livestock-images-prod/mock_image_117.jpg	{2,43}	-16.090028	-59.004583	2026-09-02 22:21:58.317959
574	327	\N	s3://livestock-images-prod/mock_image_118.jpg	{56,59,60,61}	-70.331573	-64.412142	2026-09-02 22:21:58.317959
575	343	\N	s3://livestock-images-prod/mock_image_119.jpg	{2,43,44,45,46}	-42.080431	-17.162885	2026-09-02 22:21:58.317959
576	416	\N	s3://livestock-images-prod/mock_image_120.jpg	{45}	68.713347	115.228299	2026-09-02 22:21:58.317959
577	478	Chickens	s3://livestock-images-prod/mock_image_121.jpg	{12,17,12,15,19}	54.417359	22.439139	2026-09-02 22:21:58.317959
578	223	Pigs	s3://livestock-images-prod/mock_image_122.jpg	{54,55}	41.082361	78.718244	2026-09-02 22:21:58.317959
579	362	\N	s3://livestock-images-prod/mock_image_123.jpg	{69}	79.427544	83.103569	2026-09-02 22:21:58.317959
580	310	Sheep	s3://livestock-images-prod/mock_image_124.jpg	{12,12,1,13}	81.586600	-92.009005	2026-09-02 22:21:58.317959
581	148	\N	s3://livestock-images-prod/mock_image_125.jpg	{1,3,4,5,8,11}	-25.021439	35.348268	2026-09-02 22:21:58.317959
582	131	Sheep	s3://livestock-images-prod/mock_image_126.jpg	{47,27,30,35,48,50,51,39}	67.135233	60.819171	2026-09-02 22:21:58.317959
583	95	\N	s3://livestock-images-prod/mock_image_127.jpg	{2,45,46}	-35.474312	132.400077	2026-09-02 22:21:58.317959
584	3	Cattle	s3://livestock-images-prod/mock_image_128.jpg	{27,27,52,30,48,49,50,51}	47.782613	17.965816	2026-09-02 22:21:58.317959
585	436	\N	s3://livestock-images-prod/mock_image_129.jpg	{1,27,28,29,33,34}	11.661729	162.683600	2026-09-02 22:21:58.317959
586	482	Cattle	s3://livestock-images-prod/mock_image_130.jpg	{35,62,63,64,65,66,67,68}	-2.215434	-93.628700	2026-09-02 22:21:58.317959
587	273	Cattle	s3://livestock-images-prod/mock_image_131.jpg	{25,26}	-16.508485	-36.615927	2026-09-02 22:21:58.317959
588	230	Cattle	s3://livestock-images-prod/mock_image_132.jpg	{12,12,1,13}	-6.085390	118.975608	2026-09-02 22:21:58.317959
589	430	Cattle	s3://livestock-images-prod/mock_image_133.jpg	{35,47,63,65,66,67,68}	40.906889	161.524774	2026-09-02 22:21:58.317959
590	390	\N	s3://livestock-images-prod/mock_image_134.jpg	{69}	-64.315059	108.894296	2026-09-02 22:21:58.317959
591	125	\N	s3://livestock-images-prod/mock_image_135.jpg	{1,3,4,5,7}	-63.386664	-147.301513	2026-09-02 22:21:58.317959
592	323	\N	s3://livestock-images-prod/mock_image_136.jpg	{1,2,3,4,6,7,8,9,10,11}	-26.281860	85.996770	2026-09-02 22:21:58.317959
593	328	\N	s3://livestock-images-prod/mock_image_137.jpg	{43,45}	44.324086	36.699105	2026-09-02 22:21:58.317959
594	214	\N	s3://livestock-images-prod/mock_image_138.jpg	{69}	41.418990	-138.590811	2026-09-02 22:21:58.317959
595	441	\N	s3://livestock-images-prod/mock_image_139.jpg	{27,29,34}	-23.123449	17.116047	2026-09-02 22:21:58.317959
596	81	\N	s3://livestock-images-prod/mock_image_140.jpg	{27,29,30,31,32,34,30}	-18.206527	172.519637	2026-09-02 22:21:58.317959
597	385	Turkeys	s3://livestock-images-prod/mock_image_141.jpg	{12,16,17,12,15,19,20}	34.471242	-34.384490	2026-09-02 22:21:58.317959
598	100	\N	s3://livestock-images-prod/mock_image_142.jpg	{2,60}	88.035824	19.641206	2026-09-02 22:21:58.317959
599	23	Pigs	s3://livestock-images-prod/mock_image_143.jpg	{35,53,54,55}	-12.018060	-68.571959	2026-09-02 22:21:58.317959
600	391	Turkeys	s3://livestock-images-prod/mock_image_144.jpg	{12,16,17,12,6,15,19,20}	-54.750853	13.160518	2026-09-02 22:21:58.317959
601	25	\N	s3://livestock-images-prod/mock_image_145.jpg	{1,2,3,4,5,6,7,8,24}	-18.501404	69.956709	2026-09-02 22:21:58.317959
602	223	\N	s3://livestock-images-prod/mock_image_146.jpg	{1,2,3,4,5,9,10,11}	-3.041402	-61.150905	2026-09-02 22:21:58.317959
603	408	\N	s3://livestock-images-prod/mock_image_147.jpg	{43,46}	-60.399023	-19.000115	2026-09-02 22:21:58.317959
604	128	\N	s3://livestock-images-prod/mock_image_148.jpg	{69}	0.039308	83.697531	2026-09-02 22:21:58.317959
605	434	\N	s3://livestock-images-prod/mock_image_149.jpg	{4,35,36,38,39,40,42}	-20.175996	-7.976600	2026-09-02 22:21:58.317959
606	149	\N	s3://livestock-images-prod/mock_image_150.jpg	{69}	8.318950	-109.705526	2026-09-02 22:21:58.317959
607	228	Chickens	s3://livestock-images-prod/mock_image_151.jpg	{12,17,12,6,21,22}	56.962821	-48.848027	2026-09-02 22:21:58.317959
608	100	Cattle	s3://livestock-images-prod/mock_image_152.jpg	{12,1,14}	-47.449213	12.394299	2026-09-02 22:21:58.317959
609	383	Pigs	s3://livestock-images-prod/mock_image_153.jpg	{54,55}	10.091456	87.877704	2026-09-02 22:21:58.317959
610	214	\N	s3://livestock-images-prod/mock_image_154.jpg	{2,56,58,60,61}	51.263872	165.531760	2026-09-02 22:21:58.317959
611	383	Cattle	s3://livestock-images-prod/mock_image_155.jpg	{23,24,25}	-84.973661	-22.745953	2026-09-02 22:21:58.317959
612	321	Sheep	s3://livestock-images-prod/mock_image_156.jpg	{12,13}	-57.813128	143.056495	2026-09-02 22:21:58.317959
613	84	\N	s3://livestock-images-prod/mock_image_157.jpg	{1,3,7,9}	75.421688	106.120803	2026-09-02 22:21:58.317959
614	136	Cattle	s3://livestock-images-prod/mock_image_158.jpg	{24,25,26}	9.766542	105.592552	2026-09-02 22:21:58.317959
615	425	Cattle	s3://livestock-images-prod/mock_image_159.jpg	{24,26}	89.424957	135.427919	2026-09-02 22:21:58.317959
616	157	\N	s3://livestock-images-prod/mock_image_160.jpg	{43,44,45}	29.073557	-177.960545	2026-09-02 22:21:58.317959
617	313	Cattle	s3://livestock-images-prod/mock_image_161.jpg	{47,62,63,64,66,68}	13.883420	-53.318639	2026-09-02 22:21:58.317959
618	289	\N	s3://livestock-images-prod/mock_image_162.jpg	{43,44,46}	3.874438	-156.681088	2026-09-02 22:21:58.317959
619	368	\N	s3://livestock-images-prod/mock_image_163.jpg	{2,43,44,46}	53.231655	170.650451	2026-09-02 22:21:58.317959
620	389	Cattle	s3://livestock-images-prod/mock_image_164.jpg	{47,62,63,66,67,68}	14.651452	-78.756445	2026-09-02 22:21:58.317959
621	458	\N	s3://livestock-images-prod/mock_image_165.jpg	{4,69}	61.500818	-118.540613	2026-09-02 22:21:58.317959
622	27	Cattle	s3://livestock-images-prod/mock_image_166.jpg	{35,62,63,65,66,67,68}	-13.833071	-156.719118	2026-09-02 22:21:58.317959
623	200	\N	s3://livestock-images-prod/mock_image_167.jpg	{43,45}	2.296111	95.341075	2026-09-02 22:21:58.317959
624	74	\N	s3://livestock-images-prod/mock_image_168.jpg	{43,44,45}	63.068166	29.270581	2026-09-02 22:21:58.317959
625	347	Cattle	s3://livestock-images-prod/mock_image_169.jpg	{12,12,13,54}	33.818433	77.611848	2026-09-02 22:21:58.317959
626	177	\N	s3://livestock-images-prod/mock_image_170.jpg	{43,44,45,46}	-74.495597	-12.917734	2026-09-02 22:21:58.317959
627	384	\N	s3://livestock-images-prod/mock_image_171.jpg	{2,43,44,45,46,25}	63.881310	-72.695014	2026-09-02 22:21:58.317959
628	304	\N	s3://livestock-images-prod/mock_image_172.jpg	{28,29,30,32,33,34}	9.952591	76.426655	2026-09-02 22:21:58.317959
629	304	\N	s3://livestock-images-prod/mock_image_173.jpg	{69}	9.375588	164.152391	2026-09-02 22:21:58.317959
630	414	Cattle	s3://livestock-images-prod/mock_image_174.jpg	{35,47,62,63,64,65,66}	-26.036154	21.825627	2026-09-02 22:21:58.317959
631	299	\N	s3://livestock-images-prod/mock_image_175.jpg	{2,43,44,46}	3.346834	124.906678	2026-09-02 22:21:58.317959
632	152	Sheep	s3://livestock-images-prod/mock_image_176.jpg	{12,12,13,14}	-4.192847	-8.870026	2026-09-02 22:21:58.317959
633	387	Cattle	s3://livestock-images-prod/mock_image_177.jpg	{23,24,25,26}	35.053290	-43.600897	2026-09-02 22:21:58.317959
634	380	Turkeys	s3://livestock-images-prod/mock_image_178.jpg	{12,16,17,15,18,20,21,22}	71.024691	120.287770	2026-09-02 22:21:58.317959
635	375	\N	s3://livestock-images-prod/mock_image_179.jpg	{3,4,5,6,7,9,11}	43.069391	-132.084180	2026-09-02 22:21:58.317959
636	277	\N	s3://livestock-images-prod/mock_image_180.jpg	{1,28,29,30,32,33,34}	-3.072590	86.370108	2026-09-02 22:21:58.317959
637	247	\N	s3://livestock-images-prod/mock_image_181.jpg	{44,45,46}	-48.826727	27.576360	2026-09-02 22:21:58.317959
638	50	Pigs	s3://livestock-images-prod/mock_image_182.jpg	{35,53,54,55}	-1.976923	-175.878317	2026-09-02 22:21:58.317959
639	26	Cattle	s3://livestock-images-prod/mock_image_183.jpg	{23,24,25,26}	-17.823473	86.510683	2026-09-02 22:21:58.317959
640	449	Sheep	s3://livestock-images-prod/mock_image_184.jpg	{12,12,13}	50.769348	-114.640009	2026-09-02 22:21:58.317959
641	132	Cattle	s3://livestock-images-prod/mock_image_185.jpg	{12,12,1,13,14,69}	-81.504931	76.929811	2026-09-02 22:21:58.317959
642	6	Goats	s3://livestock-images-prod/mock_image_186.jpg	{27,27,52,49,50,51}	-57.855154	74.046721	2026-09-02 22:21:58.317959
643	282	Sheep	s3://livestock-images-prod/mock_image_187.jpg	{27,35,48,49,50,51}	-44.716658	108.845974	2026-09-02 22:21:58.317959
644	434	\N	s3://livestock-images-prod/mock_image_188.jpg	{27,28,29,31,33,34}	-64.734620	112.613998	2026-09-02 22:21:58.317959
645	146	Chickens	s3://livestock-images-prod/mock_image_189.jpg	{12,16,12,15,18,20,21}	-35.552346	82.243596	2026-09-02 22:21:58.317959
646	51	\N	s3://livestock-images-prod/mock_image_190.jpg	{27,28,29,30,31,32,33}	-15.047768	154.561775	2026-09-02 22:21:58.317959
647	447	Cattle	s3://livestock-images-prod/mock_image_191.jpg	{12,1,13}	56.107676	107.404145	2026-09-02 22:21:58.317959
648	328	\N	s3://livestock-images-prod/mock_image_192.jpg	{1,5,6,7,9,10}	18.168165	-41.240616	2026-09-02 22:21:58.317959
649	369	Chickens	s3://livestock-images-prod/mock_image_193.jpg	{12,16,17,12,6,15,18,19}	-62.129403	-65.228693	2026-09-02 22:21:58.317959
650	239	Cattle	s3://livestock-images-prod/mock_image_194.jpg	{25,26,11}	13.921338	-72.481907	2026-09-02 22:21:58.317959
651	341	Cattle	s3://livestock-images-prod/mock_image_195.jpg	{47,62,66,31}	67.985930	20.411140	2026-09-02 22:21:58.317959
652	459	\N	s3://livestock-images-prod/mock_image_196.jpg	{1,2,3,4,7,8,9,11}	16.193785	-98.146157	2026-09-02 22:21:58.317959
653	224	Cattle	s3://livestock-images-prod/mock_image_197.jpg	{23,24,25,26,43}	37.877762	129.408156	2026-09-02 22:21:58.317959
654	412	Pigs	s3://livestock-images-prod/mock_image_198.jpg	{54,55}	87.202901	84.543352	2026-09-02 22:21:58.317959
655	430	Sheep	s3://livestock-images-prod/mock_image_199.jpg	{12,12,13}	-29.859535	60.630783	2026-09-02 22:21:58.317959
656	142	Cattle	s3://livestock-images-prod/mock_image_200.jpg	{27,52,30,35,48,49,50,51}	-0.827332	-134.430695	2026-09-02 22:21:58.317959
657	99	Chickens	s3://livestock-images-prod/mock_image_201.jpg	{12,16,17,12,6,15,18,19,22}	21.853962	-57.509332	2026-09-02 22:21:58.317959
658	235	Cattle	s3://livestock-images-prod/mock_image_202.jpg	{47,52,30,48,49,50,51}	16.591130	-100.000952	2026-09-02 22:21:58.317959
659	158	Sheep	s3://livestock-images-prod/mock_image_203.jpg	{47,27,27,52,30,35,48,49,50,51}	87.219074	80.842958	2026-09-02 22:21:58.317959
660	426	\N	s3://livestock-images-prod/mock_image_204.jpg	{1,27,28,29,30,33,34}	78.106593	-152.572713	2026-09-02 22:21:58.317959
661	46	\N	s3://livestock-images-prod/mock_image_205.jpg	{35,36,39,40,41}	0.313188	83.537207	2026-09-02 22:21:58.317959
662	184	Sheep	s3://livestock-images-prod/mock_image_206.jpg	{47,27,52,30,35,48,49,50,51}	-37.975816	166.870843	2026-09-02 22:21:58.317959
663	386	\N	s3://livestock-images-prod/mock_image_207.jpg	{1,2,3,4,6,7}	72.399285	-163.508534	2026-09-02 22:21:58.317959
664	152	\N	s3://livestock-images-prod/mock_image_208.jpg	{1,27,28,29,32,34}	-88.492412	-103.739315	2026-09-02 22:21:58.317959
665	185	\N	s3://livestock-images-prod/mock_image_209.jpg	{56,58,59,61,37}	89.748522	-152.672328	2026-09-02 22:21:58.317959
666	24	\N	s3://livestock-images-prod/mock_image_210.jpg	{2,43,44}	45.948963	89.659482	2026-09-02 22:21:58.317959
667	270	Pigs	s3://livestock-images-prod/mock_image_211.jpg	{55}	-81.665797	9.739450	2026-09-02 22:21:58.317959
668	362	Sheep	s3://livestock-images-prod/mock_image_212.jpg	{47,27,27,52,30,35,48,49,50,28}	43.510617	-94.030676	2026-09-02 22:21:58.317959
669	452	\N	s3://livestock-images-prod/mock_image_213.jpg	{27,28,29,33,34}	77.876128	-57.975863	2026-09-02 22:21:58.317959
670	167	\N	s3://livestock-images-prod/mock_image_214.jpg	{69}	-23.470703	117.964733	2026-09-02 22:21:58.317959
671	444	\N	s3://livestock-images-prod/mock_image_215.jpg	{2,56,58,59,60}	2.820180	144.556652	2026-09-02 22:21:58.317959
672	235	Cattle	s3://livestock-images-prod/mock_image_216.jpg	{12,12,1,13}	86.012779	92.541041	2026-09-02 22:21:58.317959
673	407	\N	s3://livestock-images-prod/mock_image_217.jpg	{69}	22.935796	-10.804956	2026-09-02 22:21:58.317959
674	380	\N	s3://livestock-images-prod/mock_image_218.jpg	{2,3,5,7,9,10,11}	86.621814	151.222148	2026-09-02 22:21:58.317959
675	59	\N	s3://livestock-images-prod/mock_image_219.jpg	{36,37,39,40}	-35.241398	104.663842	2026-09-02 22:21:58.317959
676	197	\N	s3://livestock-images-prod/mock_image_220.jpg	{4,35,37,39,40,42}	-44.070178	-64.029228	2026-09-02 22:21:58.317959
677	485	Cattle	s3://livestock-images-prod/mock_image_221.jpg	{23,24,25,26}	-63.685216	90.525322	2026-09-02 22:21:58.317959
678	175	\N	s3://livestock-images-prod/mock_image_222.jpg	{2,43,45,46}	-25.937337	74.789465	2026-09-02 22:21:58.317959
679	254	\N	s3://livestock-images-prod/mock_image_223.jpg	{27,28,29,30,31,32,33,41}	63.313191	-98.599534	2026-09-02 22:21:58.317959
680	287	Cattle	s3://livestock-images-prod/mock_image_224.jpg	{23,24,25,26,6}	32.098608	133.336494	2026-09-02 22:21:58.317959
681	38	Pigs	s3://livestock-images-prod/mock_image_225.jpg	{35,54,55}	74.133434	-144.188035	2026-09-02 22:21:58.317959
682	86	Pigs	s3://livestock-images-prod/mock_image_226.jpg	{53,54,55}	-36.320147	-20.344946	2026-09-02 22:21:58.317959
683	87	\N	s3://livestock-images-prod/mock_image_227.jpg	{27,28,30,31,32,33,34}	69.706609	-62.734101	2026-09-02 22:21:58.317959
684	64	\N	s3://livestock-images-prod/mock_image_228.jpg	{4,69}	51.251600	-139.283863	2026-09-02 22:21:58.317959
685	149	\N	s3://livestock-images-prod/mock_image_229.jpg	{2,43,44}	49.117131	162.973866	2026-09-02 22:21:58.317959
686	192	\N	s3://livestock-images-prod/mock_image_230.jpg	{4,69}	-76.561858	-37.280048	2026-09-02 22:21:58.317959
687	173	Chickens	s3://livestock-images-prod/mock_image_231.jpg	{12,16,17,12,18,19,20,21}	25.872623	168.275248	2026-09-02 22:21:58.317959
688	401	\N	s3://livestock-images-prod/mock_image_232.jpg	{69}	74.629090	138.269560	2026-09-02 22:21:58.317959
689	314	Cattle	s3://livestock-images-prod/mock_image_233.jpg	{35,62,64,65,66,67,68}	-73.666346	10.897028	2026-09-02 22:21:58.317959
690	297	\N	s3://livestock-images-prod/mock_image_234.jpg	{1,2,3,5,6,7,8,9,10,11}	3.594499	-37.894809	2026-09-02 22:21:58.317959
691	474	Cattle	s3://livestock-images-prod/mock_image_235.jpg	{24}	44.514338	-3.890491	2026-09-02 22:21:58.317959
692	188	Cattle	s3://livestock-images-prod/mock_image_236.jpg	{35,47,62,66,67,68}	16.103932	-96.788040	2026-09-02 22:21:58.317959
693	384	\N	s3://livestock-images-prod/mock_image_237.jpg	{36,37,38,40,41,42}	-69.955709	-94.851094	2026-09-02 22:21:58.317959
694	119	Cattle	s3://livestock-images-prod/mock_image_238.jpg	{12,12,13,14}	50.472945	94.424733	2026-09-02 22:21:58.317959
695	162	Sheep	s3://livestock-images-prod/mock_image_239.jpg	{12,13}	47.774564	-63.717082	2026-09-02 22:21:58.317959
696	79	Cattle	s3://livestock-images-prod/mock_image_240.jpg	{35,62,63,65,68}	79.156204	-52.529932	2026-09-02 22:21:58.317959
697	207	Chickens	s3://livestock-images-prod/mock_image_241.jpg	{12,17,12,6,15,18,19,21,22}	40.102619	-118.591631	2026-09-02 22:21:58.317959
698	188	Cattle	s3://livestock-images-prod/mock_image_242.jpg	{27,52,35,48,49,50}	-81.907779	-71.823114	2026-09-02 22:21:58.317959
699	69	\N	s3://livestock-images-prod/mock_image_243.jpg	{29,30,31,34}	49.165989	106.461678	2026-09-02 22:21:58.317959
700	145	\N	s3://livestock-images-prod/mock_image_244.jpg	{69}	59.270235	10.078162	2026-09-02 22:21:58.317959
701	279	Sheep	s3://livestock-images-prod/mock_image_245.jpg	{47,27,52,35,48,49}	6.602568	19.770266	2026-09-02 22:21:58.317959
702	140	\N	s3://livestock-images-prod/mock_image_246.jpg	{56,58}	-3.870241	-120.501131	2026-09-02 22:21:58.317959
703	264	Cattle	s3://livestock-images-prod/mock_image_247.jpg	{62,63,64,65,67}	-64.874582	-45.874354	2026-09-02 22:21:58.317959
704	421	Cattle	s3://livestock-images-prod/mock_image_248.jpg	{23,24,26}	-23.507175	143.339902	2026-09-02 22:21:58.317959
705	36	\N	s3://livestock-images-prod/mock_image_249.jpg	{69}	16.340295	19.064258	2026-09-02 22:21:58.317959
706	412	\N	s3://livestock-images-prod/mock_image_250.jpg	{1,2,4,6,7,9,10}	-6.686516	131.382318	2026-09-02 22:21:58.317959
707	323	Pigs	s3://livestock-images-prod/mock_image_251.jpg	{35,53,55}	25.382221	125.721462	2026-09-02 22:21:58.317959
708	53	\N	s3://livestock-images-prod/mock_image_252.jpg	{4}	-37.903172	-4.837146	2026-09-02 22:21:58.317959
709	173	Pigs	s3://livestock-images-prod/mock_image_253.jpg	{35,54}	-60.964521	76.379377	2026-09-02 22:21:58.317959
710	296	Goats	s3://livestock-images-prod/mock_image_254.jpg	{47,35,49,50}	-67.852279	-39.772812	2026-09-02 22:21:58.317959
711	286	Cattle	s3://livestock-images-prod/mock_image_255.jpg	{23,24,26}	19.143312	-178.780454	2026-09-02 22:21:58.317959
712	340	Cattle	s3://livestock-images-prod/mock_image_256.jpg	{24,25,26}	86.266819	-58.213893	2026-09-02 22:21:58.317959
713	441	Goats	s3://livestock-images-prod/mock_image_257.jpg	{47,27,52,30,48,49,50}	-12.179287	125.903073	2026-09-02 22:21:58.317959
714	372	\N	s3://livestock-images-prod/mock_image_258.jpg	{35,39,42}	53.460036	-89.111812	2026-09-02 22:21:58.317959
715	51	\N	s3://livestock-images-prod/mock_image_259.jpg	{2,4,6,7,9,10}	-78.187843	-69.835769	2026-09-02 22:21:58.317959
716	253	Pigs	s3://livestock-images-prod/mock_image_260.jpg	{35,53,54}	-63.326888	111.082405	2026-09-02 22:21:58.317959
717	418	\N	s3://livestock-images-prod/mock_image_261.jpg	{2,56,57,58,59,61,42}	40.532549	69.536055	2026-09-02 22:21:58.317959
718	104	Turkeys	s3://livestock-images-prod/mock_image_262.jpg	{12,16,17,12,19,20,22}	59.254545	128.455935	2026-09-02 22:21:58.317959
719	135	\N	s3://livestock-images-prod/mock_image_263.jpg	{1,2,3,6,7,8,9,11}	66.839661	-130.973321	2026-09-02 22:21:58.317959
720	99	Cattle	s3://livestock-images-prod/mock_image_264.jpg	{35,47,63,65,66,68}	-52.106007	107.896726	2026-09-02 22:21:58.317959
721	57	Cattle	s3://livestock-images-prod/mock_image_265.jpg	{12,1,13,14}	38.958337	106.288253	2026-09-02 22:21:58.317959
722	106	\N	s3://livestock-images-prod/mock_image_266.jpg	{2}	83.108684	126.853050	2026-09-02 22:21:58.317959
723	192	Cattle	s3://livestock-images-prod/mock_image_267.jpg	{27,27,52,30,35,48,49,50}	-86.380436	95.200887	2026-09-02 22:21:58.317959
724	38	Cattle	s3://livestock-images-prod/mock_image_268.jpg	{12,12,13,14}	49.897990	125.294980	2026-09-02 22:21:58.317959
725	74	\N	s3://livestock-images-prod/mock_image_269.jpg	{69}	-38.763871	41.360165	2026-09-02 22:21:58.317959
726	81	\N	s3://livestock-images-prod/mock_image_270.jpg	{28,29,30,31,33}	-82.439984	-179.314615	2026-09-02 22:21:58.317959
727	297	\N	s3://livestock-images-prod/mock_image_271.jpg	{69}	24.267518	-142.734946	2026-09-02 22:21:58.317959
728	310	Goats	s3://livestock-images-prod/mock_image_272.jpg	{27,27,49,50,51}	-26.730948	66.395362	2026-09-02 22:21:58.317959
729	146	\N	s3://livestock-images-prod/mock_image_273.jpg	{36,38,39,40,41,42}	83.307978	145.268321	2026-09-02 22:21:58.317959
730	482	Chickens	s3://livestock-images-prod/mock_image_274.jpg	{12,16,17,12,18,19,20,22}	-68.441167	66.525044	2026-09-02 22:21:58.317959
731	481	Sheep	s3://livestock-images-prod/mock_image_275.jpg	{12,1,13,14}	60.311952	150.996875	2026-09-02 22:21:58.317959
732	458	Cattle	s3://livestock-images-prod/mock_image_276.jpg	{47,62,64,67}	-50.833715	-65.035906	2026-09-02 22:21:58.317959
733	266	\N	s3://livestock-images-prod/mock_image_277.jpg	{2,56,57,58,59}	-44.643360	-29.065517	2026-09-02 22:21:58.317959
734	394	\N	s3://livestock-images-prod/mock_image_278.jpg	{3,4,7,8,9}	53.304695	21.014722	2026-09-02 22:21:58.317959
735	306	Cattle	s3://livestock-images-prod/mock_image_279.jpg	{24,25,26,36}	88.644245	178.064037	2026-09-02 22:21:58.317959
736	347	Sheep	s3://livestock-images-prod/mock_image_280.jpg	{13}	-4.982868	141.816412	2026-09-02 22:21:58.317959
737	109	\N	s3://livestock-images-prod/mock_image_281.jpg	{2,3,4,5,6,7,9,10,11}	-83.134548	-113.086605	2026-09-02 22:21:58.317959
738	66	\N	s3://livestock-images-prod/mock_image_282.jpg	{37,39,40,41,42}	58.360521	-113.007043	2026-09-02 22:21:58.317959
739	44	\N	s3://livestock-images-prod/mock_image_283.jpg	{4,69}	43.451962	137.800935	2026-09-02 22:21:58.317959
740	90	\N	s3://livestock-images-prod/mock_image_284.jpg	{4,69}	41.827881	157.415393	2026-09-02 22:21:58.317959
741	435	\N	s3://livestock-images-prod/mock_image_285.jpg	{1,28,30,31,32,33}	-85.444740	163.765322	2026-09-02 22:21:58.317959
742	62	Turkeys	s3://livestock-images-prod/mock_image_286.jpg	{12,17,12,6,15,20,21,39}	-14.572096	-145.532786	2026-09-02 22:21:58.317959
743	24	\N	s3://livestock-images-prod/mock_image_287.jpg	{2,56,57,58,59}	-18.686113	-82.392055	2026-09-02 22:21:58.317959
744	150	\N	s3://livestock-images-prod/mock_image_288.jpg	{1,27,28,29,30,31,34}	-12.034539	166.685185	2026-09-02 22:21:58.317959
745	182	\N	s3://livestock-images-prod/mock_image_289.jpg	{1,27,29,30,32,34}	-3.961536	28.971174	2026-09-02 22:21:58.317959
746	348	\N	s3://livestock-images-prod/mock_image_290.jpg	{2,45,46}	84.115353	44.182532	2026-09-02 22:21:58.317959
747	359	Pigs	s3://livestock-images-prod/mock_image_291.jpg	{53,54,55}	53.474107	92.281025	2026-09-02 22:21:58.317959
748	315	Pigs	s3://livestock-images-prod/mock_image_292.jpg	{54,55,58}	-54.957967	88.783148	2026-09-02 22:21:58.317959
749	294	\N	s3://livestock-images-prod/mock_image_293.jpg	{27,28,29,32,34}	-46.349370	111.990241	2026-09-02 22:21:58.317959
750	102	\N	s3://livestock-images-prod/mock_image_294.jpg	{2,57,58,59,60,61}	79.068200	-72.184937	2026-09-02 22:21:58.317959
751	343	Cattle	s3://livestock-images-prod/mock_image_295.jpg	{47,62,63,64,66,67}	-42.031295	-19.214634	2026-09-02 22:21:58.317959
752	134	Cattle	s3://livestock-images-prod/mock_image_296.jpg	{35,62,63,66,67,68}	3.537810	77.240725	2026-09-02 22:21:58.317959
753	305	\N	s3://livestock-images-prod/mock_image_297.jpg	{35,36,39,41,42}	22.553664	-40.305463	2026-09-02 22:21:58.317959
754	419	Turkeys	s3://livestock-images-prod/mock_image_298.jpg	{16,17,12,6,15,22}	12.555413	58.491611	2026-09-02 22:21:58.317959
755	91	\N	s3://livestock-images-prod/mock_image_299.jpg	{2,3,6,9,11,14}	58.207976	178.844271	2026-09-02 22:21:58.317959
756	59	\N	s3://livestock-images-prod/mock_image_300.jpg	{35,40,41,42}	-85.298192	-9.864594	2026-09-02 22:21:58.317959
757	430	Goats	s3://livestock-images-prod/mock_image_301.jpg	{47,27,52,30,35,48,50}	-22.786500	-175.594673	2026-09-02 22:21:58.317959
758	262	\N	s3://livestock-images-prod/mock_image_302.jpg	{2,43,44,45,46}	-20.690435	-45.035351	2026-09-02 22:21:58.317959
759	58	Cattle	s3://livestock-images-prod/mock_image_303.jpg	{23,24,25}	73.307055	-96.320556	2026-09-02 22:21:58.317959
760	93	Pigs	s3://livestock-images-prod/mock_image_304.jpg	{35,53,54,55}	-19.340172	63.039802	2026-09-02 22:21:58.317959
761	208	Sheep	s3://livestock-images-prod/mock_image_305.jpg	{47,27,27,30,35,48,49,50,51}	-21.518084	79.235073	2026-09-02 22:21:58.317959
762	384	\N	s3://livestock-images-prod/mock_image_306.jpg	{2,45,46}	28.043399	-54.487127	2026-09-02 22:21:58.317959
763	288	\N	s3://livestock-images-prod/mock_image_307.jpg	{36,37,38,39,42}	-39.592606	-104.452295	2026-09-02 22:21:58.317959
764	448	Pigs	s3://livestock-images-prod/mock_image_308.jpg	{27,52,30,35,48,51}	34.852460	111.996582	2026-09-02 22:21:58.317959
765	290	\N	s3://livestock-images-prod/mock_image_309.jpg	{56,57,58,59,60,61}	-74.504588	-72.447208	2026-09-02 22:21:58.317959
766	56	Pigs	s3://livestock-images-prod/mock_image_310.jpg	{35,53,54,55}	-69.533511	-38.840071	2026-09-02 22:21:58.317959
767	178	Sheep	s3://livestock-images-prod/mock_image_311.jpg	{12,13,14}	40.004058	17.741580	2026-09-02 22:21:58.317959
768	104	Turkeys	s3://livestock-images-prod/mock_image_312.jpg	{16,17,6,15,19,20,21}	2.957982	69.636168	2026-09-02 22:21:58.317959
769	379	\N	s3://livestock-images-prod/mock_image_313.jpg	{2,43,44,45,46}	-58.741131	97.748256	2026-09-02 22:21:58.317959
770	149	Cattle	s3://livestock-images-prod/mock_image_314.jpg	{35,62,64,66,68,34}	15.563759	-138.164022	2026-09-02 22:21:58.317959
771	84	Cattle	s3://livestock-images-prod/mock_image_315.jpg	{23,24,25,26}	-45.555890	-139.232691	2026-09-02 22:21:58.317959
772	341	\N	s3://livestock-images-prod/mock_image_316.jpg	{1,3,4,5,8,9,10}	84.509827	-36.302104	2026-09-02 22:21:58.317959
773	28	\N	s3://livestock-images-prod/mock_image_317.jpg	{27,28,29,34}	-51.734918	-154.389256	2026-09-02 22:21:58.317959
774	434	\N	s3://livestock-images-prod/mock_image_318.jpg	{1,27,28,29,32,33,34,39}	-52.363710	146.870164	2026-09-02 22:21:58.317959
775	236	Sheep	s3://livestock-images-prod/mock_image_319.jpg	{12,1,13,15}	-2.244616	159.601416	2026-09-02 22:21:58.317959
776	314	\N	s3://livestock-images-prod/mock_image_320.jpg	{45}	21.440195	-142.731046	2026-09-02 22:21:58.317959
777	494	\N	s3://livestock-images-prod/mock_image_321.jpg	{27,29,30,31,32,33,34}	88.373647	-119.145777	2026-09-02 22:21:58.317959
778	282	Cattle	s3://livestock-images-prod/mock_image_322.jpg	{25,26}	55.675415	63.126542	2026-09-02 22:21:58.317959
779	164	Pigs	s3://livestock-images-prod/mock_image_323.jpg	{35,53,54}	55.565499	-67.420927	2026-09-02 22:21:58.317959
780	194	Pigs	s3://livestock-images-prod/mock_image_324.jpg	{35,54,55}	3.632999	20.961179	2026-09-02 22:21:58.317959
781	353	\N	s3://livestock-images-prod/mock_image_325.jpg	{2,3,5,7,11}	-25.956893	-105.901712	2026-09-02 22:21:58.317959
782	132	\N	s3://livestock-images-prod/mock_image_326.jpg	{1,27,28,29,30,31,32,33}	-20.445500	18.498317	2026-09-02 22:21:58.317959
783	195	\N	s3://livestock-images-prod/mock_image_327.jpg	{35,36,38,41,42}	41.737545	102.911630	2026-09-02 22:21:58.317959
784	208	\N	s3://livestock-images-prod/mock_image_328.jpg	{1,27,28,29,30,31,32,34}	60.010309	-162.315055	2026-09-02 22:21:58.317959
785	106	\N	s3://livestock-images-prod/mock_image_329.jpg	{4,35,37,41,42}	12.648577	162.784965	2026-09-02 22:21:58.317959
786	286	Sheep	s3://livestock-images-prod/mock_image_330.jpg	{12,12,1,13}	-58.131663	24.019386	2026-09-02 22:21:58.317959
787	10	\N	s3://livestock-images-prod/mock_image_331.jpg	{1,2,4,5,6,7,8,9,11}	89.088361	16.492969	2026-09-02 22:21:58.317959
788	32	Cattle	s3://livestock-images-prod/mock_image_332.jpg	{35,62,63,64,67,68}	-84.497193	-40.297370	2026-09-02 22:21:58.317959
789	483	Cattle	s3://livestock-images-prod/mock_image_333.jpg	{23,24,25,26}	-52.643378	110.065784	2026-09-02 22:21:58.317959
790	269	Cattle	s3://livestock-images-prod/mock_image_334.jpg	{23,24,25,26}	39.835898	122.428397	2026-09-02 22:21:58.317959
791	106	Cattle	s3://livestock-images-prod/mock_image_335.jpg	{23,24,26}	84.510045	-49.760687	2026-09-02 22:21:58.317959
792	128	\N	s3://livestock-images-prod/mock_image_336.jpg	{57,58,60,61}	-76.545654	23.144764	2026-09-02 22:21:58.317959
793	163	\N	s3://livestock-images-prod/mock_image_337.jpg	{4,69}	-51.506090	-44.989614	2026-09-02 22:21:58.317959
794	267	\N	s3://livestock-images-prod/mock_image_338.jpg	{69}	-62.994178	-129.824925	2026-09-02 22:21:58.317959
795	378	Chickens	s3://livestock-images-prod/mock_image_339.jpg	{12,16,17,12,15,19,22}	-42.446760	156.047115	2026-09-02 22:21:58.317959
796	235	\N	s3://livestock-images-prod/mock_image_340.jpg	{69}	-71.127487	-35.974395	2026-09-02 22:21:58.317959
797	70	\N	s3://livestock-images-prod/mock_image_341.jpg	{35,36,37,39,42}	20.760549	-131.622606	2026-09-02 22:21:58.317959
798	209	\N	s3://livestock-images-prod/mock_image_342.jpg	{43,45,46}	81.708661	-73.905073	2026-09-02 22:21:58.317959
799	70	Pigs	s3://livestock-images-prod/mock_image_343.jpg	{54,55}	22.945673	-135.951753	2026-09-02 22:21:58.317959
800	278	\N	s3://livestock-images-prod/mock_image_344.jpg	{1,27,28,29,31,33,34}	-85.569035	28.351258	2026-09-02 22:21:58.317959
801	341	\N	s3://livestock-images-prod/mock_image_345.jpg	{4}	-14.605497	10.354107	2026-09-02 22:21:58.317959
802	356	\N	s3://livestock-images-prod/mock_image_346.jpg	{58,59,61}	66.569957	-129.471120	2026-09-02 22:21:58.317959
803	318	\N	s3://livestock-images-prod/mock_image_347.jpg	{1,3,4,5,6,8,9,11}	-89.750215	40.858392	2026-09-02 22:21:58.317959
804	184	Cattle	s3://livestock-images-prod/mock_image_348.jpg	{47,27,27,52,48,49,50,11}	37.812399	-66.500670	2026-09-02 22:21:58.317959
805	62	Chickens	s3://livestock-images-prod/mock_image_349.jpg	{12,16,17,12,15,18,19,20}	4.846696	104.442867	2026-09-02 22:21:58.317959
806	291	Turkeys	s3://livestock-images-prod/mock_image_350.jpg	{16,17,15,18,19,22}	64.548120	-25.537966	2026-09-02 22:21:58.317959
807	247	\N	s3://livestock-images-prod/mock_image_351.jpg	{1,2,4,5,6,7,9,11}	47.182878	-76.091885	2026-09-02 22:21:58.317959
808	113	Cattle	s3://livestock-images-prod/mock_image_352.jpg	{23,26}	-68.973146	172.937693	2026-09-02 22:21:58.317959
809	180	\N	s3://livestock-images-prod/mock_image_353.jpg	{1,2,3,4,5,6,7,8,9}	-23.569710	76.404741	2026-09-02 22:21:58.317959
810	26	Pigs	s3://livestock-images-prod/mock_image_354.jpg	{27,52,30,35,48,49,50,51}	-49.992823	133.755262	2026-09-02 22:21:58.317959
811	413	\N	s3://livestock-images-prod/mock_image_355.jpg	{43,45,46}	22.252644	0.851762	2026-09-02 22:21:58.317959
812	327	\N	s3://livestock-images-prod/mock_image_356.jpg	{4,36,39,40,42}	-54.912466	15.655677	2026-09-02 22:21:58.317959
813	418	Sheep	s3://livestock-images-prod/mock_image_357.jpg	{12,12,1,13}	-44.277816	80.717338	2026-09-02 22:21:58.317959
814	70	Pigs	s3://livestock-images-prod/mock_image_358.jpg	{35,54,55}	-87.026377	-39.224579	2026-09-02 22:21:58.317959
815	483	\N	s3://livestock-images-prod/mock_image_359.jpg	{4,36,37,39,41,42}	7.292841	-130.332629	2026-09-02 22:21:58.317959
816	153	\N	s3://livestock-images-prod/mock_image_360.jpg	{56,58,59,60,47}	57.603876	-113.282250	2026-09-02 22:21:58.317959
817	83	Pigs	s3://livestock-images-prod/mock_image_361.jpg	{35,53,54,55}	41.165898	23.663316	2026-09-02 22:21:58.317959
818	322	Sheep	s3://livestock-images-prod/mock_image_362.jpg	{27,27,52,30,50,51}	71.753815	129.537827	2026-09-02 22:21:58.317959
819	405	\N	s3://livestock-images-prod/mock_image_363.jpg	{2,56,57,58,61}	-31.202212	-178.667442	2026-09-02 22:21:58.317959
820	477	\N	s3://livestock-images-prod/mock_image_364.jpg	{1,27,28,29,31,32,34,32}	-61.861811	41.155799	2026-09-02 22:21:58.317959
821	49	Pigs	s3://livestock-images-prod/mock_image_365.jpg	{35,54,55}	-84.491115	156.053588	2026-09-02 22:21:58.317959
822	311	\N	s3://livestock-images-prod/mock_image_366.jpg	{35,39,41,42}	-40.333668	-38.979225	2026-09-02 22:21:58.317959
823	452	\N	s3://livestock-images-prod/mock_image_367.jpg	{4,35,36,38,39,40,42,7}	-70.919767	80.902200	2026-09-02 22:21:58.317959
824	200	\N	s3://livestock-images-prod/mock_image_368.jpg	{2,57,58,60,61}	-48.100469	-124.356356	2026-09-02 22:21:58.317959
825	13	Cattle	s3://livestock-images-prod/mock_image_369.jpg	{35,47,62,63,64,67,68}	57.150173	160.476482	2026-09-02 22:21:58.317959
826	355	\N	s3://livestock-images-prod/mock_image_370.jpg	{1,2,3,4,5,6,7,10,11}	-40.413589	-56.156259	2026-09-02 22:21:58.317959
827	140	\N	s3://livestock-images-prod/mock_image_371.jpg	{44,45,46}	80.311506	4.482834	2026-09-02 22:21:58.317959
828	451	Sheep	s3://livestock-images-prod/mock_image_372.jpg	{27,27,52,49,50}	-84.483275	84.520210	2026-09-02 22:21:58.317959
829	386	Cattle	s3://livestock-images-prod/mock_image_373.jpg	{24,25,26}	9.123399	-53.626422	2026-09-02 22:21:58.317959
830	115	\N	s3://livestock-images-prod/mock_image_374.jpg	{27,28,29,30,32,33,34,16}	13.879556	-124.598523	2026-09-02 22:21:58.317959
831	17	\N	s3://livestock-images-prod/mock_image_375.jpg	{1,2,3,4,5,7,8,11}	-84.965975	-115.770944	2026-09-02 22:21:58.317959
832	484	Goats	s3://livestock-images-prod/mock_image_376.jpg	{47,27,27,52,30,48,49,50}	-86.595073	83.491227	2026-09-02 22:21:58.317959
833	172	\N	s3://livestock-images-prod/mock_image_377.jpg	{4,35,36,38,39,40,41,42}	39.377004	87.883652	2026-09-02 22:21:58.317959
834	297	Cattle	s3://livestock-images-prod/mock_image_378.jpg	{24,25,26}	-62.450340	55.253706	2026-09-02 22:21:58.317959
835	423	Turkeys	s3://livestock-images-prod/mock_image_379.jpg	{12,16,17,12,6,15,18,19,20,22}	-41.850538	-114.937551	2026-09-02 22:21:58.317959
836	453	\N	s3://livestock-images-prod/mock_image_380.jpg	{2,44,45,46}	83.902303	-151.963146	2026-09-02 22:21:58.317959
837	193	\N	s3://livestock-images-prod/mock_image_381.jpg	{1,28,32,34,60}	55.179802	-67.663531	2026-09-02 22:21:58.317959
838	473	Cattle	s3://livestock-images-prod/mock_image_382.jpg	{24,25,26}	77.013173	-19.746892	2026-09-02 22:21:58.317959
839	347	\N	s3://livestock-images-prod/mock_image_383.jpg	{3,4,5,7,8,9,10}	-39.303685	-78.370684	2026-09-02 22:21:58.317959
840	343	Cattle	s3://livestock-images-prod/mock_image_384.jpg	{62,64,66}	-32.003476	48.246431	2026-09-02 22:21:58.317959
841	372	\N	s3://livestock-images-prod/mock_image_385.jpg	{29,30,31,32,33}	-0.695170	-3.582212	2026-09-02 22:21:58.317959
842	84	Goats	s3://livestock-images-prod/mock_image_386.jpg	{27,30,35,49,50,51}	16.554909	-158.770459	2026-09-02 22:21:58.317959
843	1	Cattle	s3://livestock-images-prod/mock_image_387.jpg	{35,62,63,64,65,66}	-14.662915	-26.717211	2026-09-02 22:21:58.317959
844	223	Goats	s3://livestock-images-prod/mock_image_388.jpg	{47,27,27,49,50}	-67.525686	-40.613525	2026-09-02 22:21:58.317959
845	381	\N	s3://livestock-images-prod/mock_image_389.jpg	{4,69}	-44.562322	113.856633	2026-09-02 22:21:58.317959
846	27	Pigs	s3://livestock-images-prod/mock_image_390.jpg	{53,54}	-4.777608	100.403638	2026-09-02 22:21:58.317959
847	185	Pigs	s3://livestock-images-prod/mock_image_391.jpg	{47,27,52,35,49,50,51}	-6.562084	170.259063	2026-09-02 22:21:58.317959
848	479	Pigs	s3://livestock-images-prod/mock_image_392.jpg	{47,27,52,30,35,48,49,50,51}	41.534523	-54.162398	2026-09-02 22:21:58.317959
849	84	\N	s3://livestock-images-prod/mock_image_393.jpg	{56,57,58,61}	20.713604	-76.190385	2026-09-02 22:21:58.317959
850	290	\N	s3://livestock-images-prod/mock_image_394.jpg	{4,69}	-63.974968	-13.699903	2026-09-02 22:21:58.317959
851	325	Cattle	s3://livestock-images-prod/mock_image_395.jpg	{47,27,27,52,35,48,49,50}	-47.977991	105.248872	2026-09-02 22:21:58.317959
852	336	\N	s3://livestock-images-prod/mock_image_396.jpg	{1,2,3,6,7,9}	-28.651408	157.232325	2026-09-02 22:21:58.317959
853	412	\N	s3://livestock-images-prod/mock_image_397.jpg	{56,58,60}	73.099917	12.357670	2026-09-02 22:21:58.317959
854	344	\N	s3://livestock-images-prod/mock_image_398.jpg	{35,38,39,41,42}	-12.532082	155.278576	2026-09-02 22:21:58.317959
855	400	Cattle	s3://livestock-images-prod/mock_image_399.jpg	{23,24,25,26}	-35.950053	177.497098	2026-09-02 22:21:58.317959
856	330	Chickens	s3://livestock-images-prod/mock_image_400.jpg	{12,16,12,6,15,18,19,20,21,22}	20.201641	128.086789	2026-09-02 22:21:58.317959
857	233	\N	s3://livestock-images-prod/mock_image_401.jpg	{2,43,44,45}	-11.746287	-30.014265	2026-09-02 22:21:58.317959
858	209	\N	s3://livestock-images-prod/mock_image_402.jpg	{1,5,7,8,9,10}	-16.839044	-62.232508	2026-09-02 22:21:58.317959
859	180	Chickens	s3://livestock-images-prod/mock_image_403.jpg	{12,16,17,12,15,19,20,22}	54.050454	-117.579096	2026-09-02 22:21:58.317959
860	141	\N	s3://livestock-images-prod/mock_image_404.jpg	{56,57,58,60}	41.339194	-179.009941	2026-09-02 22:21:58.317959
861	320	Pigs	s3://livestock-images-prod/mock_image_405.jpg	{52,48,49,50}	-18.043117	93.717613	2026-09-02 22:21:58.317959
862	316	Cattle	s3://livestock-images-prod/mock_image_406.jpg	{35,47,62,63,65,66,67}	-38.046003	-41.311401	2026-09-02 22:21:58.317959
863	440	\N	s3://livestock-images-prod/mock_image_407.jpg	{4,69}	-40.701500	160.459506	2026-09-02 22:21:58.317959
864	410	\N	s3://livestock-images-prod/mock_image_408.jpg	{43,44,45,46}	-70.276260	-114.202177	2026-09-02 22:21:58.317959
865	130	Pigs	s3://livestock-images-prod/mock_image_409.jpg	{35,54}	79.996204	-142.495171	2026-09-02 22:21:58.317959
866	397	Sheep	s3://livestock-images-prod/mock_image_410.jpg	{47,27,52,30,48,49,50,51}	42.346366	-76.146331	2026-09-02 22:21:58.317959
867	254	\N	s3://livestock-images-prod/mock_image_411.jpg	{69}	64.294975	28.123013	2026-09-02 22:21:58.317959
868	478	\N	s3://livestock-images-prod/mock_image_412.jpg	{4,35,36,37,38,39,41,42}	51.046130	138.689822	2026-09-02 22:21:58.317959
869	295	Chickens	s3://livestock-images-prod/mock_image_413.jpg	{12,16,17,12,15,18,20,21}	44.144030	-64.637305	2026-09-02 22:21:58.317959
870	447	\N	s3://livestock-images-prod/mock_image_414.jpg	{69}	70.374865	89.387449	2026-09-02 22:21:58.317959
871	50	\N	s3://livestock-images-prod/mock_image_415.jpg	{2,56,59}	-0.343056	125.687058	2026-09-02 22:21:58.317959
872	16	Chickens	s3://livestock-images-prod/mock_image_416.jpg	{12,16,17,12,15,18,19,20,21,22}	66.751438	75.192688	2026-09-02 22:21:58.317959
873	389	Chickens	s3://livestock-images-prod/mock_image_417.jpg	{12,16,12,6,15,20,22}	-25.824281	68.087408	2026-09-02 22:21:58.317959
874	462	Chickens	s3://livestock-images-prod/mock_image_418.jpg	{12,16,17,12,6,15,18,19,20,22}	-87.231814	174.597368	2026-09-02 22:21:58.317959
875	356	Cattle	s3://livestock-images-prod/mock_image_419.jpg	{47,62,63,16}	-44.758130	4.970516	2026-09-02 22:21:58.317959
876	414	Chickens	s3://livestock-images-prod/mock_image_420.jpg	{17,12,6,15,18,19,20}	42.395276	75.609740	2026-09-02 22:21:58.317959
877	475	Sheep	s3://livestock-images-prod/mock_image_421.jpg	{12,12,13,14}	-86.131578	30.601044	2026-09-02 22:21:58.317959
878	159	Chickens	s3://livestock-images-prod/mock_image_422.jpg	{16,12,6,15,20}	2.888513	85.941215	2026-09-02 22:21:58.317959
879	141	\N	s3://livestock-images-prod/mock_image_423.jpg	{1,27,28,29,31,32,33,34}	60.696140	-104.370441	2026-09-02 22:21:58.317959
880	445	\N	s3://livestock-images-prod/mock_image_424.jpg	{69}	-57.706609	133.557540	2026-09-02 22:21:58.317959
881	239	Cattle	s3://livestock-images-prod/mock_image_425.jpg	{23,24,25,26}	-66.194350	-28.665561	2026-09-02 22:21:58.317959
882	251	\N	s3://livestock-images-prod/mock_image_426.jpg	{69}	19.290570	109.680398	2026-09-02 22:21:58.317959
883	400	\N	s3://livestock-images-prod/mock_image_427.jpg	{2,56,57,58,59,23}	78.828649	-63.088634	2026-09-02 22:21:58.317959
884	341	\N	s3://livestock-images-prod/mock_image_428.jpg	{35,36,37,38,39,40,42}	-47.790308	-177.981197	2026-09-02 22:21:58.317959
885	41	Chickens	s3://livestock-images-prod/mock_image_429.jpg	{12,16,17,12,15,20,22}	-85.191164	115.405934	2026-09-02 22:21:58.317959
886	105	\N	s3://livestock-images-prod/mock_image_430.jpg	{4,35,38,39,42}	-89.135612	-64.403780	2026-09-02 22:21:58.317959
887	490	\N	s3://livestock-images-prod/mock_image_431.jpg	{45,46}	26.185431	-79.705350	2026-09-02 22:21:58.317959
888	281	\N	s3://livestock-images-prod/mock_image_432.jpg	{35,37,38,40,42}	-1.308476	-178.445855	2026-09-02 22:21:58.317959
889	223	Pigs	s3://livestock-images-prod/mock_image_433.jpg	{35,54,55,29}	56.198329	-162.183625	2026-09-02 22:21:58.317959
890	54	\N	s3://livestock-images-prod/mock_image_434.jpg	{2,46}	9.378464	-60.628936	2026-09-02 22:21:58.317959
891	346	Turkeys	s3://livestock-images-prod/mock_image_435.jpg	{12,16,17,12,6,15,18,19,20,22}	50.552901	-152.768845	2026-09-02 22:21:58.317959
892	160	\N	s3://livestock-images-prod/mock_image_436.jpg	{2,43,44,45,46}	-33.731272	87.095776	2026-09-02 22:21:58.317959
893	474	Cattle	s3://livestock-images-prod/mock_image_437.jpg	{23,24,25,26}	67.701033	-59.430939	2026-09-02 22:21:58.317959
894	80	Chickens	s3://livestock-images-prod/mock_image_438.jpg	{12,16,17,12,18,21}	-2.603582	-47.490549	2026-09-02 22:21:58.317959
895	309	Pigs	s3://livestock-images-prod/mock_image_439.jpg	{35,53,54,55}	-74.346323	-133.545989	2026-09-02 22:21:58.317959
896	342	\N	s3://livestock-images-prod/mock_image_440.jpg	{43,44}	24.120105	-32.019631	2026-09-02 22:21:58.317959
897	26	\N	s3://livestock-images-prod/mock_image_441.jpg	{56,58,60}	-32.981206	-86.237319	2026-09-02 22:21:58.317959
898	304	\N	s3://livestock-images-prod/mock_image_442.jpg	{35,36,37,40,42}	-67.518884	-10.733871	2026-09-02 22:21:58.317959
899	94	Cattle	s3://livestock-images-prod/mock_image_443.jpg	{27,27,52,30,49,50}	-39.534285	-87.359001	2026-09-02 22:21:58.317959
900	436	Sheep	s3://livestock-images-prod/mock_image_444.jpg	{12,12,1,13,14}	-11.757123	-143.350905	2026-09-02 22:21:58.317959
901	224	Chickens	s3://livestock-images-prod/mock_image_445.jpg	{12,16,17,12,6,18,20,22}	65.801080	-178.763863	2026-09-02 22:21:58.317959
902	10	\N	s3://livestock-images-prod/mock_image_446.jpg	{1,2,3,8,9,11}	-51.338665	-93.849080	2026-09-02 22:21:58.317959
903	108	\N	s3://livestock-images-prod/mock_image_447.jpg	{27,28,29,31,32}	12.981627	-97.857703	2026-09-02 22:21:58.317959
904	178	Cattle	s3://livestock-images-prod/mock_image_448.jpg	{23,24,25,26}	8.284469	15.189414	2026-09-02 22:21:58.317959
905	401	Pigs	s3://livestock-images-prod/mock_image_449.jpg	{35,53,54,52}	-33.236279	-19.589756	2026-09-02 22:21:58.317959
906	208	Cattle	s3://livestock-images-prod/mock_image_450.jpg	{27,27,52,49,50}	89.816845	-71.421413	2026-09-02 22:21:58.317959
907	461	\N	s3://livestock-images-prod/mock_image_451.jpg	{36,40,42}	-9.982205	165.614722	2026-09-02 22:21:58.317959
908	245	\N	s3://livestock-images-prod/mock_image_452.jpg	{69}	78.623721	-119.593954	2026-09-02 22:21:58.317959
909	439	Turkeys	s3://livestock-images-prod/mock_image_453.jpg	{16,17,12,6,15,18,19,22}	57.291513	171.778034	2026-09-02 22:21:58.317959
910	320	Pigs	s3://livestock-images-prod/mock_image_454.jpg	{54,55}	24.847140	-1.078326	2026-09-02 22:21:58.317959
911	28	\N	s3://livestock-images-prod/mock_image_455.jpg	{1,3,6,8,11}	84.063611	72.763761	2026-09-02 22:21:58.317959
912	163	\N	s3://livestock-images-prod/mock_image_456.jpg	{1,4,5,7,8,10}	31.258064	-140.548115	2026-09-02 22:21:58.317959
913	452	\N	s3://livestock-images-prod/mock_image_457.jpg	{69}	-7.439074	-9.458385	2026-09-02 22:21:58.317959
914	9	\N	s3://livestock-images-prod/mock_image_458.jpg	{1,28,29,31,33,34}	85.183715	-107.727133	2026-09-02 22:21:58.317959
915	204	\N	s3://livestock-images-prod/mock_image_459.jpg	{2,57,58,61}	-18.296252	6.008059	2026-09-02 22:21:58.317959
916	25	\N	s3://livestock-images-prod/mock_image_460.jpg	{2,3,4,5,6,8,9}	-61.090313	-4.718690	2026-09-02 22:21:58.317959
917	445	\N	s3://livestock-images-prod/mock_image_461.jpg	{36,38,39,41,42}	37.797893	-159.111931	2026-09-02 22:21:58.317959
918	424	Pigs	s3://livestock-images-prod/mock_image_462.jpg	{53,54}	-14.056941	162.829274	2026-09-02 22:21:58.317959
919	164	Sheep	s3://livestock-images-prod/mock_image_463.jpg	{47,52,30,49,50,51}	-69.678697	106.470153	2026-09-02 22:21:58.317959
920	264	Pigs	s3://livestock-images-prod/mock_image_464.jpg	{27,27,52,30,35,49,50,51}	85.776339	-28.591411	2026-09-02 22:21:58.317959
921	475	Cattle	s3://livestock-images-prod/mock_image_465.jpg	{47,27,52,30,48,49,50}	74.321685	-118.884319	2026-09-02 22:21:58.317959
922	290	Cattle	s3://livestock-images-prod/mock_image_466.jpg	{23,24,25,26}	-44.617592	122.217417	2026-09-02 22:21:58.317959
923	2	\N	s3://livestock-images-prod/mock_image_467.jpg	{57,58,59,61}	68.768509	100.741228	2026-09-02 22:21:58.317959
924	25	Chickens	s3://livestock-images-prod/mock_image_468.jpg	{12,16,17,12,6,18,19,20,21,22}	68.784766	160.717494	2026-09-02 22:21:58.317959
925	107	Cattle	s3://livestock-images-prod/mock_image_469.jpg	{35,47,63,65,68,42}	-4.490650	52.005881	2026-09-02 22:21:58.317959
926	17	Cattle	s3://livestock-images-prod/mock_image_470.jpg	{24,25,26}	55.432699	26.473593	2026-09-02 22:21:58.317959
927	255	\N	s3://livestock-images-prod/mock_image_471.jpg	{36,39,40,41,42}	-35.794272	102.340338	2026-09-02 22:21:58.317959
928	83	Pigs	s3://livestock-images-prod/mock_image_472.jpg	{53,54,55}	63.881640	93.747657	2026-09-02 22:21:58.317959
929	248	\N	s3://livestock-images-prod/mock_image_473.jpg	{56,57,58,59,60}	63.207666	59.147305	2026-09-02 22:21:58.317959
930	277	Cattle	s3://livestock-images-prod/mock_image_474.jpg	{25,26}	52.863028	87.186662	2026-09-02 22:21:58.317959
931	25	Sheep	s3://livestock-images-prod/mock_image_475.jpg	{12,12,1,13,14}	-87.723079	73.323101	2026-09-02 22:21:58.317959
932	222	\N	s3://livestock-images-prod/mock_image_476.jpg	{1,2,3,4,5,6,7,8,10,11}	-29.516501	124.762515	2026-09-02 22:21:58.317959
933	283	Pigs	s3://livestock-images-prod/mock_image_477.jpg	{53,54,55}	36.926029	106.608067	2026-09-02 22:21:58.317959
934	116	\N	s3://livestock-images-prod/mock_image_478.jpg	{2,43,45,46}	15.891924	160.550904	2026-09-02 22:21:58.317959
935	348	\N	s3://livestock-images-prod/mock_image_479.jpg	{69}	84.086273	53.643371	2026-09-02 22:21:58.317959
936	132	Sheep	s3://livestock-images-prod/mock_image_480.jpg	{12,1,13}	78.692090	-170.918390	2026-09-02 22:21:58.317959
937	343	\N	s3://livestock-images-prod/mock_image_481.jpg	{2,56,58,59}	-43.014620	159.646028	2026-09-02 22:21:58.317959
938	483	\N	s3://livestock-images-prod/mock_image_482.jpg	{43,45,46}	31.342990	-32.971524	2026-09-02 22:21:58.317959
939	34	\N	s3://livestock-images-prod/mock_image_483.jpg	{4,35,36,39,42}	-85.009736	-110.870808	2026-09-02 22:21:58.317959
940	263	Cattle	s3://livestock-images-prod/mock_image_484.jpg	{47,27,52,30,48,49,50}	2.671584	-171.771889	2026-09-02 22:21:58.317959
941	412	Cattle	s3://livestock-images-prod/mock_image_485.jpg	{35,62,63,64,67,68}	-67.348674	121.238023	2026-09-02 22:21:58.317959
942	162	\N	s3://livestock-images-prod/mock_image_486.jpg	{4,69}	-83.387547	-166.461077	2026-09-02 22:21:58.317959
943	171	Cattle	s3://livestock-images-prod/mock_image_487.jpg	{23,24,25,26}	-11.254090	5.286319	2026-09-02 22:21:58.317959
944	329	Cattle	s3://livestock-images-prod/mock_image_488.jpg	{35,47,62,63,66}	77.954832	-22.409636	2026-09-02 22:21:58.317959
945	254	\N	s3://livestock-images-prod/mock_image_489.jpg	{28,29,30,32,34}	-19.337439	92.181860	2026-09-02 22:21:58.317959
946	465	\N	s3://livestock-images-prod/mock_image_490.jpg	{69}	-20.597226	30.166529	2026-09-02 22:21:58.317959
947	88	\N	s3://livestock-images-prod/mock_image_491.jpg	{1,27,28,29,31,33,34}	54.538364	69.560135	2026-09-02 22:21:58.317959
948	329	\N	s3://livestock-images-prod/mock_image_492.jpg	{4,69}	-59.359125	-118.130216	2026-09-02 22:21:58.317959
949	470	\N	s3://livestock-images-prod/mock_image_493.jpg	{43,44,45,46,1}	-11.738337	165.335323	2026-09-02 22:21:58.317959
950	253	\N	s3://livestock-images-prod/mock_image_494.jpg	{1,29,30,32,34}	49.063827	175.069886	2026-09-02 22:21:58.317959
951	382	Chickens	s3://livestock-images-prod/mock_image_495.jpg	{12,16,17,19,20,21,18}	-13.754256	18.402272	2026-09-02 22:21:58.317959
952	334	\N	s3://livestock-images-prod/mock_image_496.jpg	{2,43,45,46}	7.162044	144.992668	2026-09-02 22:21:58.317959
953	66	\N	s3://livestock-images-prod/mock_image_497.jpg	{56,57,58,59,61}	-56.953286	-4.401797	2026-09-02 22:21:58.317959
954	313	\N	s3://livestock-images-prod/mock_image_498.jpg	{69}	-33.628968	-59.243235	2026-09-02 22:21:58.317959
955	214	\N	s3://livestock-images-prod/mock_image_499.jpg	{1,3,4,7,10}	-27.160883	-164.796926	2026-09-02 22:21:58.317959
956	102	\N	s3://livestock-images-prod/mock_image_500.jpg	{4,69}	7.898752	-48.592226	2026-09-02 22:21:58.317959
\.


--
-- Data for Name: lab_reports; Type: TABLE DATA; Schema: public; Owner: parag
--

COPY public.lab_reports (lab_report_id, report_id, lab_technician_id, confirmed_disease_id, test_method, test_results, is_final_truth, used_in_training, verified_at) FROM stdin;
147	461	557	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
148	463	569	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
149	466	555	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
150	470	566	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
151	472	569	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
152	481	555	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
153	485	556	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
154	490	566	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
155	496	554	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
156	499	556	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
157	502	557	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
158	506	567	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
159	510	554	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
160	512	559	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
161	513	568	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
162	514	563	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
163	516	551	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
164	521	558	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
165	522	558	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
166	527	555	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
167	529	559	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
168	533	555	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
169	535	556	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
170	539	568	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
171	540	567	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
172	543	559	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
173	553	558	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
174	554	570	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
175	560	561	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
176	564	566	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
177	567	554	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
178	568	553	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
179	570	565	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
180	571	565	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
181	574	553	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
182	577	556	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
183	581	553	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
184	584	568	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
185	588	564	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
186	591	564	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
187	599	559	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
188	603	564	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
189	604	560	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
190	608	555	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
191	611	565	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
192	615	561	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
193	620	553	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
194	621	553	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
195	623	559	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
196	624	563	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
197	631	564	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
198	634	558	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
199	638	564	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
200	639	552	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
201	643	560	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
202	644	557	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
203	645	557	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
204	648	555	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
205	650	551	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
206	654	555	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
207	656	565	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
208	658	567	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
209	661	569	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
210	663	565	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
211	664	552	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
212	675	554	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
213	679	557	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
214	680	559	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
215	681	559	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
216	683	558	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
217	684	555	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
218	689	553	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
219	694	556	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
220	704	554	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
221	706	555	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
222	710	553	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
223	712	566	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
224	719	559	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
225	728	557	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
226	730	560	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
227	731	559	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
228	733	557	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
229	734	566	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
230	735	568	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
231	740	558	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
232	741	555	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
233	745	565	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
234	752	562	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
235	755	552	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
236	756	565	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
237	760	560	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
238	765	564	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
239	768	563	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
240	770	567	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
241	787	557	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
242	789	555	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
243	790	556	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
244	796	558	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
245	797	563	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
246	798	555	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
247	801	566	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
248	802	557	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
249	804	556	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
250	808	555	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
251	815	566	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
252	818	566	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
253	819	561	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
254	820	551	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
255	822	555	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
256	823	566	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
257	824	551	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
258	826	552	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
259	830	561	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
260	831	562	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
261	832	560	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
262	833	565	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
263	836	554	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
264	837	562	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
265	838	555	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
266	840	553	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
267	842	564	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
268	850	565	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
269	853	554	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
270	854	568	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
271	856	567	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
272	857	563	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
273	858	566	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
274	860	566	10	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
275	862	566	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
276	880	552	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
277	881	552	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
278	884	553	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
279	890	558	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
280	898	556	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
281	899	561	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
282	900	564	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
283	908	562	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
284	909	564	3	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
285	916	558	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
286	917	552	6	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
287	918	557	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
288	920	558	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
289	921	554	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
290	922	554	4	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
291	925	560	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
292	932	569	1	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
293	933	553	9	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
294	934	562	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
295	936	561	2	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
296	938	555	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
297	940	567	8	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
298	941	563	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
299	944	569	11	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
300	945	551	5	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
301	952	552	7	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
302	956	567	12	PCR Test	Confirmed positive	t	f	2026-09-02 22:21:58.317959
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
329	458	543	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
330	460	504	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
331	461	506	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
332	462	502	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
333	463	549	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
334	464	517	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
335	465	518	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
336	468	523	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
337	469	542	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
338	470	518	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
339	471	541	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
340	473	544	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
341	474	534	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
342	475	536	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
343	477	507	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
344	478	516	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
345	479	518	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
346	480	522	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
347	481	514	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
348	484	525	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
349	485	546	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
350	487	545	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
351	488	550	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
352	489	513	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
353	490	521	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
354	491	506	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
355	492	512	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
356	494	538	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
357	496	539	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
358	497	512	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
359	498	535	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
360	499	521	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
361	500	533	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
362	501	530	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
363	502	529	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
364	503	520	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
365	505	504	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
366	506	531	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
367	507	519	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
368	508	547	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
369	509	502	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
370	510	525	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
371	512	526	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
372	515	537	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
373	516	507	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
374	517	508	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
375	518	534	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
376	521	539	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
377	525	515	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
378	526	526	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
379	527	524	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
380	528	535	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
381	529	547	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
382	530	513	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
383	532	515	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
384	533	527	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
385	535	516	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
386	537	544	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
387	539	549	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
388	540	533	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
389	542	510	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
390	543	536	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
391	546	541	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
392	547	503	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
393	548	524	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
394	550	526	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
395	554	543	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
396	555	525	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
397	556	529	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
398	560	505	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
399	561	535	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
400	562	523	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
401	563	523	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
402	564	540	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
403	567	535	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
404	568	543	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
405	569	539	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
406	570	550	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
407	571	501	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
408	572	521	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
409	573	511	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
410	574	546	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
411	575	529	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
412	576	539	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
413	577	516	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
414	579	509	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
415	580	550	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
416	581	534	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
417	582	514	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
418	585	511	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
419	586	534	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
420	587	523	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
421	588	536	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
422	589	516	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
423	591	513	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
424	592	532	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
425	593	514	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
426	594	546	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
427	595	502	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
428	596	530	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
429	597	511	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
430	598	529	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
431	603	526	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
432	606	527	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
433	607	518	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
434	608	522	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
435	609	548	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
436	610	526	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
437	612	536	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
438	615	536	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
439	616	522	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
440	617	501	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
441	619	523	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
442	620	530	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
443	621	534	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
444	622	518	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
445	623	511	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
446	624	527	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
447	625	535	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
448	626	547	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
449	627	510	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
450	628	525	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
451	629	524	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
452	630	520	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
453	631	526	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
454	634	547	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
455	635	540	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
456	637	548	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
457	638	546	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
458	641	501	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
459	642	544	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
460	643	520	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
461	644	547	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
462	645	533	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
463	646	507	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
464	648	535	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
465	649	528	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
466	650	512	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
467	651	519	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
468	654	522	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
469	655	503	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
470	656	535	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
471	657	544	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
472	658	543	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
473	660	513	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
474	661	522	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
475	662	547	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
476	665	511	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
477	666	539	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
478	667	537	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
479	668	505	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
480	669	510	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
481	670	532	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
482	672	532	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
483	674	525	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
484	676	533	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
485	677	527	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
486	678	523	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
487	679	504	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
488	680	535	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
489	681	508	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
490	683	523	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
491	684	511	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
492	685	509	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
493	686	550	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
494	687	523	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
495	688	533	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
496	689	528	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
497	690	548	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
498	691	537	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
499	692	512	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
500	693	549	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
501	694	509	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
502	695	542	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
503	697	512	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
504	698	531	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
505	701	532	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
506	702	536	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
507	704	518	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
508	705	547	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
509	706	539	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
510	707	504	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
511	709	531	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
512	710	536	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
513	711	544	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
514	712	521	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
515	714	529	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
516	715	511	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
517	716	533	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
518	717	525	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
519	718	516	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
520	719	540	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
521	722	550	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
522	723	533	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
523	724	509	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
524	726	546	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
525	727	519	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
526	729	528	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
527	730	508	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
528	731	522	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
529	732	534	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
530	736	513	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
531	737	532	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
532	739	546	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
533	740	523	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
534	741	532	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
535	744	522	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
536	745	521	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
537	746	509	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
538	747	521	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
539	750	501	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
540	751	546	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
541	753	504	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
542	754	522	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
543	755	550	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
544	757	523	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
545	758	533	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
546	759	545	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
547	761	523	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
548	762	525	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
549	764	508	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
550	765	512	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
551	766	549	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
552	767	532	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
553	768	535	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
554	769	543	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
555	770	524	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
556	772	524	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
557	773	533	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
558	774	546	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
559	776	547	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
560	777	538	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
561	779	537	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
562	780	511	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
563	781	517	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
564	784	544	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
565	785	525	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
566	786	524	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
567	787	528	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
568	789	546	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
569	790	515	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
570	791	526	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
571	792	533	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
572	793	517	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
573	794	546	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
574	795	501	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
575	796	543	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
576	798	507	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
577	799	510	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
578	800	535	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
579	801	516	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
580	802	540	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
581	803	541	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
582	804	501	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
583	806	524	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
584	807	533	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
585	808	532	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
586	809	501	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
587	810	532	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
588	813	506	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
589	814	517	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
590	815	505	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
591	816	508	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
592	817	507	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
593	818	540	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
594	819	514	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
595	820	521	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
596	823	517	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
597	824	511	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
598	825	532	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
599	826	541	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
600	827	516	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
601	829	545	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
602	831	507	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
603	834	528	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
604	835	530	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
605	836	538	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
606	837	506	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
607	838	550	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
608	839	540	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
609	841	534	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
610	844	508	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
611	845	506	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
612	846	503	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
613	848	548	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
614	849	531	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
615	851	532	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
616	854	518	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
617	855	532	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
618	859	523	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
619	860	524	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
620	862	549	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
621	863	538	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
622	864	516	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
623	866	541	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
624	870	542	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
625	874	548	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
626	875	537	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
627	876	539	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
628	877	525	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
629	878	509	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
630	881	525	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
631	882	517	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
632	885	524	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
633	887	531	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
634	888	511	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
635	889	544	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
636	890	529	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
637	892	511	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
638	893	505	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
639	894	528	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
640	895	523	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
641	897	528	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
642	898	527	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
643	899	550	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
644	901	523	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
645	902	530	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
646	903	539	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
647	905	546	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
648	906	540	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
649	908	533	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
650	910	516	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
651	912	503	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
652	913	526	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
653	914	516	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
654	915	518	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
655	916	514	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
656	919	546	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
657	920	514	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
658	921	541	8	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
659	922	522	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
660	923	522	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
661	924	528	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
662	925	548	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
663	926	520	4	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
664	927	547	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
665	928	532	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
666	929	544	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
667	931	521	2	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
668	932	535	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
669	933	508	9	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
670	934	529	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
671	935	533	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
672	937	522	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
673	938	539	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
674	939	521	6	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
675	941	535	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
676	942	525	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
677	944	529	11	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
678	945	519	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
679	946	517	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
680	949	537	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
681	950	549	5	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
682	951	543	3	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
683	952	514	7	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
684	953	530	10	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
685	954	506	12	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
686	955	518	1	t	Realistic notes matching expected symptoms	\N	f	2026-09-02 22:21:58.317959
\.


--
-- Name: diseases_disease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.diseases_disease_id_seq', 12, true);


--
-- Name: field_reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.field_reports_report_id_seq', 956, true);


--
-- Name: lab_reports_lab_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.lab_reports_lab_report_id_seq', 302, true);


--
-- Name: model_versions_model_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.model_versions_model_version_id_seq', 3, true);


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

SELECT pg_catalog.setval('public.triage_results_triage_id_seq', 300, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.users_user_id_seq', 570, true);


--
-- Name: vet_verifications_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parag
--

SELECT pg_catalog.setval('public.vet_verifications_verification_id_seq', 686, true);


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

\unrestrict U1mf5fzAuxYzhD1y77XIXeZesK7QrRxGawjYOcfiUzcMgjaYD6JaR8PU9gK6c0z

