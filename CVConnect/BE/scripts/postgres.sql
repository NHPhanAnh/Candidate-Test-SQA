--
-- PostgreSQL database dump
--

\restrict rWMYT8mqI1GVkplEjzT721KFJPeDxCFrHaXn1geWQedoL2NdYSiFOhCruXVMg8T

-- Dumped from database version 14.22 (Debian 14.22-1.pgdg13+1)
-- Dumped by pg_dump version 14.22 (Debian 14.22-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: func_filter_job_ad_outside(text, boolean, bigint[], bigint[], text, boolean, integer, integer, boolean, text, boolean, bigint, integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_filter_job_ad_outside(p_keyword text DEFAULT NULL::text, p_is_show_expired boolean DEFAULT false, p_career_ids bigint[] DEFAULT NULL::bigint[], p_level_ids bigint[] DEFAULT NULL::bigint[], p_job_ad_location text DEFAULT NULL::text, p_is_remote boolean DEFAULT NULL::boolean, p_salary_from integer DEFAULT NULL::integer, p_salary_to integer DEFAULT NULL::integer, p_negotiable boolean DEFAULT NULL::boolean, p_job_type text DEFAULT NULL::text, p_search_org boolean DEFAULT NULL::boolean, p_org_id bigint DEFAULT NULL::bigint, p_limit integer DEFAULT 10, p_offset integer DEFAULT 0, p_sort_by text DEFAULT 'created_at'::text, p_sort_direction text DEFAULT 'desc'::text) RETURNS TABLE(id bigint, code character varying, title character varying, orgid bigint, positionid bigint, jobtype character varying, duedate timestamp without time zone, quantity integer, salarytype character varying, salaryfrom integer, salaryto integer, currencytype character varying, keyword character varying, description text, requirement text, benefit text, hrcontactid bigint, jobadstatus character varying, ispublic boolean, isautosendemail boolean, emailtemplateid bigint, isremote boolean, isalllevel boolean, keycodeinternal character varying, isactive boolean, isdeleted boolean, createdby character varying, createdat timestamp without time zone, updatedby character varying, updatedat timestamp without time zone, viewcount bigint)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE format($f$
        SELECT DISTINCT ja.id,
                        ja.code,
                        ja.title,
                        ja.org_id,
                        ja.position_id,
                        ja.job_type,
                        ja.due_date::timestamp,
                        ja.quantity,
                        ja.salary_type,
                        ja.salary_from,
                        case when ja.salary_to is null then 0 else ja.salary_to end as salary_to,
                        ja.currency_type,
                        ja.keyword,
                        ja.description,
                        ja.requirement,
                        ja.benefit,
                        ja.hr_contact_id,
                        ja.job_ad_status,
                        ja.is_public,
                        ja.is_auto_send_email,
                        ja.email_template_id,
                        ja.is_remote,
                        ja.is_all_level,
                        ja.key_code_internal,
                        ja.is_active,
                        ja.is_deleted,
                        ja.created_by,
                        ja.created_at::timestamp,
                        ja.updated_by,
                        ja.updated_at::timestamp,
                        case when jas.view_count is null then 0 else jas.view_count end as view_count
        FROM job_ad ja
        LEFT JOIN job_ad_career jac ON jac.job_ad_id = ja.id
        LEFT JOIN job_ad_level jal ON jal.job_ad_id = ja.id
        LEFT JOIN job_ad_work_location jawl ON jawl.job_ad_id = ja.id
        LEFT JOIN organization_address oa ON oa.id = jawl.work_location_id
        LEFT JOIN job_ad_statistic jas ON jas.job_ad_id = ja.id
        JOIN organization o ON o.id = ja.org_id AND o.is_active = true
        WHERE ja.is_public = true
          AND (%L = true OR ja.job_ad_status = 'OPEN')
          AND (%L = true OR ja.due_date >= CURRENT_DATE)
          AND (%L IS NULL OR jac.career_id = ANY(%L))
          AND (%L IS NULL OR jal.level_id = ANY(%L))
          AND (%L IS NULL OR (oa.province IS NOT NULL AND lower(oa.province) LIKE lower('%%' || %L || '%%')))
          AND (%L IS NULL OR ja.is_remote = %L)
          AND (%L IS NULL OR (ja.salary_from IS NOT NULL AND ja.salary_from <= %L))
          AND (%L IS NULL OR (ja.salary_to IS NOT NULL AND %L <= ja.salary_to))
          AND (%L IS NULL OR ja.salary_type = 'NEGOTIABLE')
          AND (%L IS NULL OR ja.job_type = %L)
          AND (%L IS NULL OR ja.org_id = %L)
          AND (%L IS NULL
               OR (%L = true AND lower(o.name) LIKE lower('%%' || %L || '%%'))
               OR ts_rank(to_tsvector(ja.title || ' ' || replace(ja.keyword, ';', ' ')), plainto_tsquery(%L)) > 0.05
               OR similarity(ja.title || ' ' || replace(ja.keyword, ';', ' '), %L) > 0.3)
        ORDER BY %I %s, created_at DESC
        LIMIT %s OFFSET %s
        $f$,
        p_is_show_expired,
        p_is_show_expired,
        p_career_ids, p_career_ids,
        p_level_ids, p_level_ids,
        p_job_ad_location, p_job_ad_location,
        p_is_remote, p_is_remote,
        p_salary_from, p_salary_from,
        p_salary_to, p_salary_to,
        p_negotiable,
        p_job_type, p_job_type,
        p_org_id, p_org_id,
        p_keyword,
        p_search_org, p_keyword,
        p_keyword, p_keyword,
        p_sort_by, p_sort_direction,
        p_limit, p_offset
    );
END;
$_$;


ALTER FUNCTION public.func_filter_job_ad_outside(p_keyword text, p_is_show_expired boolean, p_career_ids bigint[], p_level_ids bigint[], p_job_ad_location text, p_is_remote boolean, p_salary_from integer, p_salary_to integer, p_negotiable boolean, p_job_type text, p_search_org boolean, p_org_id bigint, p_limit integer, p_offset integer, p_sort_by text, p_sort_direction text) OWNER TO postgres;

--
-- Name: func_working_location_outside(text, boolean, bigint[], bigint[], text, boolean, integer, integer, boolean, text, boolean, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_working_location_outside(p_keyword text DEFAULT NULL::text, p_is_show_expired boolean DEFAULT false, p_career_ids bigint[] DEFAULT NULL::bigint[], p_level_ids bigint[] DEFAULT NULL::bigint[], p_job_ad_location text DEFAULT NULL::text, p_is_remote boolean DEFAULT NULL::boolean, p_salary_from integer DEFAULT NULL::integer, p_salary_to integer DEFAULT NULL::integer, p_negotiable boolean DEFAULT NULL::boolean, p_job_type text DEFAULT NULL::text, p_search_org boolean DEFAULT NULL::boolean, p_org_id bigint DEFAULT NULL::bigint) RETURNS TABLE(id bigint, isremote boolean, province character varying)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE format($f$
        SELECT DISTINCT ja.id,
                        ja.is_remote,
                        oa.province
        FROM job_ad ja
        LEFT JOIN job_ad_career jac ON jac.job_ad_id = ja.id
        LEFT JOIN job_ad_level jal ON jal.job_ad_id = ja.id
        LEFT JOIN job_ad_work_location jawl ON jawl.job_ad_id = ja.id
        LEFT JOIN organization_address oa ON oa.id = jawl.work_location_id
        JOIN organization o ON o.id = ja.org_id AND o.is_active = true
        WHERE ja.is_public = true
          AND ja.job_ad_status = 'OPEN'
          AND (%L = true OR ja.due_date >= CURRENT_DATE)
          AND (%L IS NULL OR jac.career_id = ANY(%L))
          AND (%L IS NULL OR jal.level_id = ANY(%L))
          AND (%L IS NULL OR (oa.province IS NOT NULL AND lower(oa.province) LIKE lower('%%' || %L || '%%')))
          AND (%L IS NULL OR ja.is_remote = %L)
          AND (%L IS NULL OR (ja.salary_from IS NOT NULL AND ja.salary_from <= %L))
          AND (%L IS NULL OR (ja.salary_to IS NOT NULL AND %L <= ja.salary_to))
          AND (%L IS NULL OR ja.salary_type = 'NEGOTIABLE')
          AND (%L IS NULL OR ja.job_type = %L)
          AND (%L IS NULL OR ja.org_id = %L)
          AND (%L IS NULL
               OR (%L = true AND lower(o.name) LIKE lower('%%' || %L || '%%'))
               OR ts_rank(to_tsvector(ja.title || ' ' || replace(ja.keyword, ';', ' ')), plainto_tsquery(%L)) > 0.05
               OR similarity(ja.title || ' ' || replace(ja.keyword, ';', ' '), %L) > 0.3)
        $f$,
        p_is_show_expired,
        p_career_ids, p_career_ids,
        p_level_ids, p_level_ids,
        p_job_ad_location, p_job_ad_location,
        p_is_remote, p_is_remote,
        p_salary_from, p_salary_from,
        p_salary_to, p_salary_to,
        p_negotiable,
        p_job_type, p_job_type,
        p_org_id, p_org_id,
        p_keyword,
        p_search_org, p_keyword,
        p_keyword, p_keyword
    );
END;
$_$;


ALTER FUNCTION public.func_working_location_outside(p_keyword text, p_is_show_expired boolean, p_career_ids bigint[], p_level_ids bigint[], p_job_ad_location text, p_is_remote boolean, p_salary_from integer, p_salary_to integer, p_negotiable boolean, p_job_type text, p_search_org boolean, p_org_id bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attach_file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attach_file (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    base_filename character varying(255) NOT NULL,
    extension character varying(50) NOT NULL,
    filename character varying(255) NOT NULL,
    folder character varying(255),
    format character varying(100),
    original_filename character varying(255) NOT NULL,
    public_id character varying(255) NOT NULL,
    resource_type character varying(100) NOT NULL,
    secure_url character varying(500) NOT NULL,
    type character varying(100) NOT NULL,
    url character varying(500) NOT NULL
);


ALTER TABLE public.attach_file OWNER TO postgres;

--
-- Name: attach_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attach_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attach_file_id_seq OWNER TO postgres;

--
-- Name: attach_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attach_file_id_seq OWNED BY public.attach_file.id;


--
-- Name: calendar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendar (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    calendar_type character varying(100) NOT NULL,
    creator_id bigint NOT NULL,
    date date NOT NULL,
    duration_minutes integer NOT NULL,
    job_ad_process_id bigint NOT NULL,
    join_same_time boolean DEFAULT false,
    meeting_link character varying(500),
    note text,
    org_address_id bigint,
    time_from time(6) without time zone NOT NULL
);


ALTER TABLE public.calendar OWNER TO postgres;

--
-- Name: calendar_candidate_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendar_candidate_info (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    calendar_id bigint NOT NULL,
    candidate_info_id bigint NOT NULL,
    date date NOT NULL,
    time_from time(6) without time zone NOT NULL,
    time_to time(6) without time zone NOT NULL
);


ALTER TABLE public.calendar_candidate_info OWNER TO postgres;

--
-- Name: calendar_candidate_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calendar_candidate_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_candidate_info_id_seq OWNER TO postgres;

--
-- Name: calendar_candidate_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calendar_candidate_info_id_seq OWNED BY public.calendar_candidate_info.id;


--
-- Name: calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_id_seq OWNER TO postgres;

--
-- Name: calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calendar_id_seq OWNED BY public.calendar.id;


--
-- Name: candidate_evaluation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidate_evaluation (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    comments text NOT NULL,
    evaluator_id bigint NOT NULL,
    job_ad_process_candidate_id bigint NOT NULL,
    score numeric(38,2)
);


ALTER TABLE public.candidate_evaluation OWNER TO postgres;

--
-- Name: candidate_evaluation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.candidate_evaluation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidate_evaluation_id_seq OWNER TO postgres;

--
-- Name: candidate_evaluation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.candidate_evaluation_id_seq OWNED BY public.candidate_evaluation.id;


--
-- Name: candidate_info_apply; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidate_info_apply (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    candidate_id bigint NOT NULL,
    cover_letter text,
    cv_file_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(50)
);


ALTER TABLE public.candidate_info_apply OWNER TO postgres;

--
-- Name: candidate_info_apply_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.candidate_info_apply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidate_info_apply_id_seq OWNER TO postgres;

--
-- Name: candidate_info_apply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.candidate_info_apply_id_seq OWNED BY public.candidate_info_apply.id;


--
-- Name: candidate_summary_org; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidate_summary_org (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    candidate_info_id bigint NOT NULL,
    level_id bigint NOT NULL,
    org_id bigint NOT NULL,
    skill text
);


ALTER TABLE public.candidate_summary_org OWNER TO postgres;

--
-- Name: candidate_summary_org_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.candidate_summary_org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidate_summary_org_id_seq OWNER TO postgres;

--
-- Name: candidate_summary_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.candidate_summary_org_id_seq OWNED BY public.candidate_summary_org.id;


--
-- Name: careers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.careers (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.careers OWNER TO postgres;

--
-- Name: careers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.careers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.careers_id_seq OWNER TO postgres;

--
-- Name: careers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.careers_id_seq OWNED BY public.careers.id;


--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    org_id bigint NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_id_seq OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.department.id;


--
-- Name: failed_rollback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_rollback (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(100),
    is_active boolean,
    is_deleted boolean,
    updated_at timestamp(6) with time zone,
    updated_by character varying(100),
    error_message text,
    payload text NOT NULL,
    retry_count integer DEFAULT 0,
    status boolean DEFAULT false,
    type character varying(100) NOT NULL
);


ALTER TABLE public.failed_rollback OWNER TO postgres;

--
-- Name: failed_rollback_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_rollback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.failed_rollback_id_seq OWNER TO postgres;

--
-- Name: failed_rollback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_rollback_id_seq OWNED BY public.failed_rollback.id;


--
-- Name: industry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industry (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    description text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.industry OWNER TO postgres;

--
-- Name: industry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.industry_id_seq OWNER TO postgres;

--
-- Name: industry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industry_id_seq OWNED BY public.industry.id;


--
-- Name: interview_panel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interview_panel (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    calendar_id bigint NOT NULL,
    interviewer_id bigint NOT NULL
);


ALTER TABLE public.interview_panel OWNER TO postgres;

--
-- Name: interview_panel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.interview_panel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.interview_panel_id_seq OWNER TO postgres;

--
-- Name: interview_panel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.interview_panel_id_seq OWNED BY public.interview_panel.id;


--
-- Name: job_ad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    benefit text,
    code character varying(50) NOT NULL,
    currency_type character varying(50) NOT NULL,
    description text,
    due_date timestamp(6) with time zone NOT NULL,
    email_template_id bigint,
    hr_contact_id bigint NOT NULL,
    is_all_level boolean,
    is_auto_send_email boolean DEFAULT false,
    is_public boolean DEFAULT true,
    is_remote boolean,
    job_ad_status character varying(100) NOT NULL,
    job_type character varying(100) NOT NULL,
    key_code_internal character varying(255),
    keyword character varying(255),
    org_id bigint NOT NULL,
    position_id bigint NOT NULL,
    quantity integer DEFAULT 1,
    requirement text,
    salary_from integer,
    salary_to integer,
    salary_type character varying(100) NOT NULL,
    title character varying(255) NOT NULL
);


ALTER TABLE public.job_ad OWNER TO postgres;

--
-- Name: job_ad_candidate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_candidate (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    apply_date timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    candidate_info_id bigint NOT NULL,
    candidate_status character varying(100) NOT NULL,
    eliminate_date timestamp(6) with time zone,
    eliminate_reason_detail text,
    eliminate_reason_type text,
    job_ad_id bigint NOT NULL,
    onboard_date timestamp(6) with time zone
);


ALTER TABLE public.job_ad_candidate OWNER TO postgres;

--
-- Name: job_ad_candidate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_candidate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_candidate_id_seq OWNER TO postgres;

--
-- Name: job_ad_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_candidate_id_seq OWNED BY public.job_ad_candidate.id;


--
-- Name: job_ad_career; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_career (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    career_id bigint NOT NULL,
    job_ad_id bigint NOT NULL
);


ALTER TABLE public.job_ad_career OWNER TO postgres;

--
-- Name: job_ad_career_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_career_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_career_id_seq OWNER TO postgres;

--
-- Name: job_ad_career_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_career_id_seq OWNED BY public.job_ad_career.id;


--
-- Name: job_ad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_id_seq OWNER TO postgres;

--
-- Name: job_ad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_id_seq OWNED BY public.job_ad.id;


--
-- Name: job_ad_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_level (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    job_ad_id bigint NOT NULL,
    level_id bigint NOT NULL
);


ALTER TABLE public.job_ad_level OWNER TO postgres;

--
-- Name: job_ad_level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_level_id_seq OWNER TO postgres;

--
-- Name: job_ad_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_level_id_seq OWNED BY public.job_ad_level.id;


--
-- Name: job_ad_process; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_process (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    job_ad_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    process_type_id bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.job_ad_process OWNER TO postgres;

--
-- Name: job_ad_process_candidate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_process_candidate (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    action_date timestamp(6) with time zone,
    is_current_process boolean DEFAULT false,
    job_ad_candidate_id bigint NOT NULL,
    job_ad_process_id bigint NOT NULL
);


ALTER TABLE public.job_ad_process_candidate OWNER TO postgres;

--
-- Name: job_ad_process_candidate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_process_candidate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_process_candidate_id_seq OWNER TO postgres;

--
-- Name: job_ad_process_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_process_candidate_id_seq OWNED BY public.job_ad_process_candidate.id;


--
-- Name: job_ad_process_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_process_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_process_id_seq OWNER TO postgres;

--
-- Name: job_ad_process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_process_id_seq OWNED BY public.job_ad_process.id;


--
-- Name: job_ad_statistic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_statistic (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    job_ad_id bigint NOT NULL,
    view_count bigint DEFAULT 0
);


ALTER TABLE public.job_ad_statistic OWNER TO postgres;

--
-- Name: job_ad_statistic_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_statistic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_statistic_id_seq OWNER TO postgres;

--
-- Name: job_ad_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_statistic_id_seq OWNED BY public.job_ad_statistic.id;


--
-- Name: job_ad_work_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad_work_location (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    job_ad_id bigint NOT NULL,
    work_location_id bigint NOT NULL
);


ALTER TABLE public.job_ad_work_location OWNER TO postgres;

--
-- Name: job_ad_work_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_work_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_work_location_id_seq OWNER TO postgres;

--
-- Name: job_ad_work_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_work_location_id_seq OWNED BY public.job_ad_work_location.id;


--
-- Name: job_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_config (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    description character varying(500),
    expression character varying(100) NOT NULL,
    job_name character varying(100) NOT NULL,
    schedule_type character varying(50) NOT NULL,
    CONSTRAINT job_config_schedule_type_check CHECK (((schedule_type)::text = ANY ((ARRAY['CRON'::character varying, 'FIXED_RATE'::character varying, 'FIXED_DELAY'::character varying])::text[])))
);


ALTER TABLE public.job_config OWNER TO postgres;

--
-- Name: job_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_config_id_seq OWNER TO postgres;

--
-- Name: job_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_config_id_seq OWNED BY public.job_config.id;


--
-- Name: level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    is_default boolean DEFAULT false,
    name character varying(255) NOT NULL
);


ALTER TABLE public.level OWNER TO postgres;

--
-- Name: level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.level_id_seq OWNER TO postgres;

--
-- Name: level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.level_id_seq OWNED BY public.level.id;


--
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    cover_photo_id bigint,
    description text,
    logo_id bigint,
    name character varying(255) NOT NULL,
    staff_count_from integer,
    staff_count_to integer,
    website character varying(255)
);


ALTER TABLE public.organization OWNER TO postgres;

--
-- Name: organization_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_address (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    detail_address character varying(255) NOT NULL,
    district character varying(150),
    is_headquarter boolean DEFAULT false,
    org_id bigint NOT NULL,
    province character varying(150) NOT NULL,
    ward character varying(150)
);


ALTER TABLE public.organization_address OWNER TO postgres;

--
-- Name: organization_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organization_address_id_seq OWNER TO postgres;

--
-- Name: organization_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_address_id_seq OWNED BY public.organization_address.id;


--
-- Name: organization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organization_id_seq OWNER TO postgres;

--
-- Name: organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_id_seq OWNED BY public.organization.id;


--
-- Name: organization_industry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_industry (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    industry_id bigint NOT NULL,
    org_id bigint NOT NULL
);


ALTER TABLE public.organization_industry OWNER TO postgres;

--
-- Name: organization_industry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_industry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organization_industry_id_seq OWNER TO postgres;

--
-- Name: organization_industry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_industry_id_seq OWNED BY public.organization_industry.id;


--
-- Name: position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."position" (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    department_id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public."position" OWNER TO postgres;

--
-- Name: position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_id_seq OWNER TO postgres;

--
-- Name: position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.position_id_seq OWNED BY public."position".id;


--
-- Name: position_process; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.position_process (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    name character varying(255) NOT NULL,
    position_id bigint NOT NULL,
    process_type_id bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.position_process OWNER TO postgres;

--
-- Name: position_process_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.position_process_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_process_id_seq OWNER TO postgres;

--
-- Name: position_process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.position_process_id_seq OWNED BY public.position_process.id;


--
-- Name: process_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.process_type (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    code character varying(50) NOT NULL,
    is_default boolean DEFAULT false,
    name character varying(255) NOT NULL,
    sort_order integer DEFAULT 0
);


ALTER TABLE public.process_type OWNER TO postgres;

--
-- Name: process_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.process_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.process_type_id_seq OWNER TO postgres;

--
-- Name: process_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.process_type_id_seq OWNED BY public.process_type.id;


--
-- Name: search_history_outside; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.search_history_outside (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    created_by character varying(255),
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    updated_at timestamp(6) with time zone,
    updated_by character varying(255),
    keyword character varying(255),
    user_id bigint
);


ALTER TABLE public.search_history_outside OWNER TO postgres;

--
-- Name: search_history_outside_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.search_history_outside_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.search_history_outside_id_seq OWNER TO postgres;

--
-- Name: search_history_outside_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.search_history_outside_id_seq OWNED BY public.search_history_outside.id;


--
-- Name: attach_file id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attach_file ALTER COLUMN id SET DEFAULT nextval('public.attach_file_id_seq'::regclass);


--
-- Name: calendar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar ALTER COLUMN id SET DEFAULT nextval('public.calendar_id_seq'::regclass);


--
-- Name: calendar_candidate_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_candidate_info ALTER COLUMN id SET DEFAULT nextval('public.calendar_candidate_info_id_seq'::regclass);


--
-- Name: candidate_evaluation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_evaluation ALTER COLUMN id SET DEFAULT nextval('public.candidate_evaluation_id_seq'::regclass);


--
-- Name: candidate_info_apply id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_info_apply ALTER COLUMN id SET DEFAULT nextval('public.candidate_info_apply_id_seq'::regclass);


--
-- Name: candidate_summary_org id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_summary_org ALTER COLUMN id SET DEFAULT nextval('public.candidate_summary_org_id_seq'::regclass);


--
-- Name: careers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.careers ALTER COLUMN id SET DEFAULT nextval('public.careers_id_seq'::regclass);


--
-- Name: department id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: failed_rollback id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_rollback ALTER COLUMN id SET DEFAULT nextval('public.failed_rollback_id_seq'::regclass);


--
-- Name: industry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry ALTER COLUMN id SET DEFAULT nextval('public.industry_id_seq'::regclass);


--
-- Name: interview_panel id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interview_panel ALTER COLUMN id SET DEFAULT nextval('public.interview_panel_id_seq'::regclass);


--
-- Name: job_ad id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad ALTER COLUMN id SET DEFAULT nextval('public.job_ad_id_seq'::regclass);


--
-- Name: job_ad_candidate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_candidate ALTER COLUMN id SET DEFAULT nextval('public.job_ad_candidate_id_seq'::regclass);


--
-- Name: job_ad_career id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_career ALTER COLUMN id SET DEFAULT nextval('public.job_ad_career_id_seq'::regclass);


--
-- Name: job_ad_level id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_level ALTER COLUMN id SET DEFAULT nextval('public.job_ad_level_id_seq'::regclass);


--
-- Name: job_ad_process id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_process ALTER COLUMN id SET DEFAULT nextval('public.job_ad_process_id_seq'::regclass);


--
-- Name: job_ad_process_candidate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_process_candidate ALTER COLUMN id SET DEFAULT nextval('public.job_ad_process_candidate_id_seq'::regclass);


--
-- Name: job_ad_statistic id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_statistic ALTER COLUMN id SET DEFAULT nextval('public.job_ad_statistic_id_seq'::regclass);


--
-- Name: job_ad_work_location id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_work_location ALTER COLUMN id SET DEFAULT nextval('public.job_ad_work_location_id_seq'::regclass);


--
-- Name: job_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_config ALTER COLUMN id SET DEFAULT nextval('public.job_config_id_seq'::regclass);


--
-- Name: level id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level ALTER COLUMN id SET DEFAULT nextval('public.level_id_seq'::regclass);


--
-- Name: organization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT nextval('public.organization_id_seq'::regclass);


--
-- Name: organization_address id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_address ALTER COLUMN id SET DEFAULT nextval('public.organization_address_id_seq'::regclass);


--
-- Name: organization_industry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_industry ALTER COLUMN id SET DEFAULT nextval('public.organization_industry_id_seq'::regclass);


--
-- Name: position id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position" ALTER COLUMN id SET DEFAULT nextval('public.position_id_seq'::regclass);


--
-- Name: position_process id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.position_process ALTER COLUMN id SET DEFAULT nextval('public.position_process_id_seq'::regclass);


--
-- Name: process_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_type ALTER COLUMN id SET DEFAULT nextval('public.process_type_id_seq'::regclass);


--
-- Name: search_history_outside id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.search_history_outside ALTER COLUMN id SET DEFAULT nextval('public.search_history_outside_id_seq'::regclass);


--
-- Data for Name: attach_file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attach_file (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, base_filename, extension, filename, folder, format, original_filename, public_id, resource_type, secure_url, type, url) FROM stdin;
1	2026-03-27 15:45:28.44983+00	Hung@123	t	f	\N	\N	kiemtra01_01.05_anhtd	pdf	kiemtra01_01.05_anhtd_1774626324607	cv-connect/Hung@123	pdf	kiemtra01_01.05_anhtd.pdf	cv-connect/Hung@123/kiemtra01_01.05_anhtd_1774626324607	image	https://res.cloudinary.com/dbz0omjn3/image/upload/v1774626328/cv-connect/Hung%40123/kiemtra01_01.05_anhtd_1774626324607.pdf	upload	http://res.cloudinary.com/dbz0omjn3/image/upload/v1774626328/cv-connect/Hung%40123/kiemtra01_01.05_anhtd_1774626324607.pdf
2	2026-03-27 16:27:18.731177+00	internal	t	f	\N	\N	táº£i xuá»‘ng	jpg	táº£i xuá»‘ng_1774628835563	cv-connect/internal	jpg	táº£i xuá»‘ng.jpg	cv-connect/internal/táº£i xuá»‘ng_1774628835563	image	https://res.cloudinary.com/dbz0omjn3/image/upload/v1774628837/cv-connect/internal/t%E1%BA%A3i%20xu%E1%BB%91ng_1774628835563.jpg	upload	http://res.cloudinary.com/dbz0omjn3/image/upload/v1774628837/cv-connect/internal/t%E1%BA%A3i%20xu%E1%BB%91ng_1774628835563.jpg
3	2026-03-27 16:27:18.783473+00	internal	t	f	\N	\N	táº£i xuá»‘ng (1)	jpg	táº£i xuá»‘ng (1)_1774628837459	cv-connect/internal	jpg	táº£i xuá»‘ng (1).jpg	cv-connect/internal/táº£i xuá»‘ng (1)_1774628837459	image	https://res.cloudinary.com/dbz0omjn3/image/upload/v1774628838/cv-connect/internal/t%E1%BA%A3i%20xu%E1%BB%91ng%20%281%29_1774628837459.jpg	upload	http://res.cloudinary.com/dbz0omjn3/image/upload/v1774628838/cv-connect/internal/t%E1%BA%A3i%20xu%E1%BB%91ng%20%281%29_1774628837459.jpg
4	2026-03-27 18:17:52.986367+00	Hung123456	t	f	\N	\N	kiemtra01_01.05_anhtd	pdf	kiemtra01_01.05_anhtd_1774635463105	cv-connect/Hung123456	pdf	kiemtra01_01.05_anhtd.pdf	cv-connect/Hung123456/kiemtra01_01.05_anhtd_1774635463105	image	https://res.cloudinary.com/dbz0omjn3/image/upload/v1774635469/cv-connect/Hung123456/kiemtra01_01.05_anhtd_1774635463105.pdf	upload	http://res.cloudinary.com/dbz0omjn3/image/upload/v1774635469/cv-connect/Hung123456/kiemtra01_01.05_anhtd_1774635463105.pdf
5	2026-03-29 16:38:13.346744+00	Uvien@123	t	f	\N	\N	CV_TEST	pdf	CV_TEST_1774802289976	cv-connect/Uvien@123	pdf	CV_TEST.pdf	cv-connect/Uvien@123/CV_TEST_1774802289976	image	https://res.cloudinary.com/dbz0omjn3/image/upload/v1774802292/cv-connect/Uvien%40123/CV_TEST_1774802289976.pdf	upload	http://res.cloudinary.com/dbz0omjn3/image/upload/v1774802292/cv-connect/Uvien%40123/CV_TEST_1774802289976.pdf
\.


--
-- Data for Name: calendar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calendar (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, calendar_type, creator_id, date, duration_minutes, job_ad_process_id, join_same_time, meeting_link, note, org_address_id, time_from) FROM stdin;
1	2026-03-29 17:50:29.428469+00	HUngHR123	t	f	\N	\N	INTERVIEW_OFFLINE	13	2026-03-31	20	5	f	\N	\N	3	00:50:00
\.


--
-- Data for Name: calendar_candidate_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calendar_candidate_info (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, calendar_id, candidate_info_id, date, time_from, time_to) FROM stdin;
1	2026-03-29 17:50:29.493394+00	HUngHR123	t	f	\N	\N	1	3	2026-03-31	00:50:00	01:10:00
\.


--
-- Data for Name: candidate_evaluation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.candidate_evaluation (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, comments, evaluator_id, job_ad_process_candidate_id, score) FROM stdin;
1	2026-03-29 17:35:29.650092+00	HUngHR123	t	f	\N	\N	á»•n	13	8	8.00
\.


--
-- Data for Name: candidate_info_apply; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.candidate_info_apply (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, candidate_id, cover_letter, cv_file_id, email, full_name, phone) FROM stdin;
1	2026-03-27 15:45:28.499294+00	Hung@123	t	f	\N	\N	7		1	nguyenhsf@gmail.com	hung nguyen manh	09127123
2	2026-03-27 18:17:52.998524+00	Hung123456	t	f	\N	\N	8		4	DUC@gmail.com	DUC	09123132122
3	2026-03-29 16:38:13.396443+00	Uvien@123	t	f	\N	\N	25		5	hung2233250904@gmail.com	Ung vien 1	0912886123
\.


--
-- Data for Name: candidate_summary_org; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.candidate_summary_org (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, candidate_info_id, level_id, org_id, skill) FROM stdin;
1	2026-03-29 18:54:02.601689+00	HUngHR123	t	f	\N	\N	3	4	3	\N
\.


--
-- Data for Name: careers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.careers (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, name) FROM stdin;
3	\N	seed	t	f	\N	\N	BE	Backend Developer
4	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	IT	CĂ´ng nghá»‡ thĂ´ng tin
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	SALES	Kinh doanh / BĂ¡n hĂ ng
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	MARKETING	Marketing
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	HR	NhĂ¢n sá»±
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	ACCOUNTING	Káº¿ toĂ¡n / TĂ i chĂ­nh
9	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	DESIGN	Thiáº¿t káº¿
10	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	CS	ChÄƒm sĂ³c khĂ¡ch hĂ ng
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, name, org_id) FROM stdin;
2	\N	seed	t	f	\N	\N	ENG	Engineering	2
3	2026-03-27 17:20:20.861265+00	HUngHR123	t	f	\N	\N	1122	IT	3
4	2026-03-27 18:08:38.048942+00	HUngHR123	t	f	\N	\N	2211	Marketing	3
\.


--
-- Data for Name: failed_rollback; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_rollback (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, error_message, payload, retry_count, status, type) FROM stdin;
\.


--
-- Data for Name: industry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industry (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, description, name) FROM stdin;
1	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	IT	\N	CĂ´ng nghá»‡ thĂ´ng tin
2	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	EDU	\N	GiĂ¡o dá»¥c & ÄĂ o táº¡o
3	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	FIN	\N	TĂ i chĂ­nh - NgĂ¢n hĂ ng
4	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	INS	\N	Báº£o hiá»ƒm
5	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	HEA	\N	Y táº¿ & ChÄƒm sĂ³c sá»©c khá»e
6	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	REA	\N	Báº¥t Ä‘á»™ng sáº£n
7	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	CON	\N	XĂ¢y dá»±ng
8	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	MAN	\N	Sáº£n xuáº¥t - Cháº¿ biáº¿n
9	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	TRA	\N	ThÆ°Æ¡ng máº¡i - BĂ¡n láº»
10	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	AGR	\N	NĂ´ng nghiá»‡p & Thá»§y sáº£n
11	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	LOG	\N	Giao thĂ´ng váº­n táº£i & Logistics
12	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	ENE	\N	NÄƒng lÆ°á»£ng
13	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	TEL	\N	Viá»…n thĂ´ng
14	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	MED	\N	Truyá»n thĂ´ng & Giáº£i trĂ­
15	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	TOU	\N	Du lá»‹ch & KhĂ¡ch sáº¡n
16	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	LAW	\N	Luáº­t & Dá»‹ch vá»¥ phĂ¡p lĂ½
17	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	HR	\N	NhĂ¢n sá»± & Tuyá»ƒn dá»¥ng
18	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	FOO	\N	Thá»±c pháº©m & Äá»“ uá»‘ng
19	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	FAS	\N	Thá»i trang & Má»¹ pháº©m
20	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	PUB	\N	Dá»‹ch vá»¥ cĂ´ng (ChĂ­nh phá»§, HĂ nh chĂ­nh)
21	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	AUT	\N	Ă” tĂ´ & CĂ´ng nghiá»‡p phá»¥ trá»£
22	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	AVI	\N	HĂ ng khĂ´ng & VÅ© trá»¥
23	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	MAR	\N	HĂ ng háº£i & ÄĂ³ng tĂ u
24	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	ELE	\N	Äiá»‡n tá»­ & CÆ¡ Ä‘iá»‡n tá»­
25	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	MEC	\N	CÆ¡ khĂ­ & Cháº¿ táº¡o mĂ¡y
26	2026-03-27 16:13:39.863813+00	admin	t	f	\N	\N	MIN	\N	Khai khoĂ¡ng & KhoĂ¡ng sáº£n
\.


--
-- Data for Name: interview_panel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interview_panel (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, calendar_id, interviewer_id) FROM stdin;
1	2026-03-29 17:50:29.47841+00	HUngHR123	t	f	\N	\N	1	7
\.


--
-- Data for Name: job_ad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, benefit, code, currency_type, description, due_date, email_template_id, hr_contact_id, is_all_level, is_auto_send_email, is_public, is_remote, job_ad_status, job_type, key_code_internal, keyword, org_id, position_id, quantity, requirement, salary_from, salary_to, salary_type, title) FROM stdin;
1	\N	seed	t	f	\N	\N	Laptop, bonus, flexible time.	JD-DEMO-001	VND	Build backend services with Spring Boot.	2026-04-26 14:27:17.740445+00	\N	1	f	f	t	f	OPEN	FULL_TIME	b7c33abd5095819dc5275fdd78e5afe6	java;spring;postgresql;microservice	2	2	3	1+ year Java/Spring experience.	15000000	25000000	RANGE	Backend Developer (Java Spring)
2	\N	seed	t	f	\N	\N	Health insurance, remote 2 days/week.	JD-DEMO-002	VND	Build modern web UI.	2026-05-11 14:27:17.749042+00	\N	1	f	f	t	t	OPEN	FULL_TIME	2ee53cf3a021982397f4ea8a14548d58	vue;nuxt;typescript;frontend	2	2	2	Experience with Vue/Nuxt.	12000000	22000000	RANGE	Frontend Developer (Vue/Nuxt)
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_03	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	FULL_TIME	\N	sales,executive	2	2	1	1+ year Java/Spring experience.	10000000	14000000	RANGE	Sales Executive
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_04	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	CONTRACT	\N	business,development,associate	2	2	1	1+ year Java/Spring experience.	11000000	15000000	RANGE	Business Development Associate
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_05	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	FULL_TIME	\N	marketing,specialist	2	2	1	1+ year Java/Spring experience.	15000000	19000000	RANGE	Marketing Specialist
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_06	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	PART_TIME	\N	content,marketing,executive	2	2	1	1+ year Java/Spring experience.	16000000	20000000	RANGE	Content Marketing Executive
9	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_07	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	FULL_TIME	\N	hr,executive	2	2	1	1+ year Java/Spring experience.	20000000	24000000	RANGE	HR Executive
10	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_08	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	CONTRACT	\N	talent,acquisition,specialist	2	2	1	1+ year Java/Spring experience.	21000000	25000000	RANGE	Talent Acquisition Specialist
11	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_09	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	FULL_TIME	\N	accountant	2	2	1	1+ year Java/Spring experience.	25000000	29000000	RANGE	Accountant
12	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_10	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	PART_TIME	\N	financial,analyst	2	2	1	1+ year Java/Spring experience.	26000000	30000000	RANGE	Financial Analyst
13	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_11	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	FULL_TIME	\N	ui,designer	2	2	1	1+ year Java/Spring experience.	30000000	45000000	RANGE	UI Designer
14	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_12	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	CONTRACT	\N	product,designer	2	2	1	1+ year Java/Spring experience.	32000000	50000000	RANGE	Product Designer
15	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_13	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	FULL_TIME	\N	customer,support,lead	2	2	1	1+ year Java/Spring experience.	51000000	65000000	RANGE	Customer Support Lead
16	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_14	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	PART_TIME	\N	customer,success,manager	2	2	1	1+ year Java/Spring experience.	55000000	70000000	RANGE	Customer Success Manager
17	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_15	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	CONTRACT	\N	java,backend,developer,(negotiable)	2	2	1	1+ year Java/Spring experience.	\N	\N	NEGOTIABLE	Java Backend Developer (Negotiable)
18	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	Laptop, bonus, flexible time.	SEED_20260327_16	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	FULL_TIME	\N	vue,frontend,developer,(negotiable)	2	2	1	1+ year Java/Spring experience.	\N	\N	NEGOTIABLE	Vue Frontend Developer (Negotiable)
3	2026-03-27 14:57:37.262207+00	seed	t	f	2026-03-27 15:01:34.341362+00	seed	Laptop, bonus, flexible time.	SEED_20260327_01	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	f	OPEN	FULL_TIME	\N	intern,java,developer	2	2	1	1+ year Java/Spring experience.	0	60000000	RANGE	Intern Java Developer
4	2026-03-27 14:57:37.262207+00	seed	t	f	2026-03-27 15:01:34.341362+00	seed	Laptop, bonus, flexible time.	SEED_20260327_02	VND	Build backend services with Spring Boot.	2026-05-26 14:57:37.262207+00	\N	1	f	f	t	t	OPEN	PART_TIME	\N	fresher,frontend,developer	2	2	1	1+ year Java/Spring experience.	0	60000000	RANGE	Fresher Frontend Developer
19	2026-03-27 17:54:15.653377+00	HUngHR123	t	f	2026-03-30 02:58:02.7744+00	HUngHR123		JD-1	VND	<p>đŸ‘‰</p><ul class="list-disc ml-4"><li><p>Tham gia phĂ¡t triá»ƒn há»‡ thá»‘ng backend sá»­ dá»¥ng Spring Boot</p></li><li><p>XĂ¢y dá»±ng vĂ  tá»‘i Æ°u RESTful APIs</p></li><li><p>LĂ m viá»‡c vá»›i database PostgreSQL/MySQL</p></li><li><p>Phá»‘i há»£p vá»›i team frontend (ReactJS) Ä‘á»ƒ tĂ­ch há»£p há»‡ thá»‘ng</p></li><li><p>Tham gia review code vĂ  cáº£i tiáº¿n há»‡ thá»‘ng</p></li></ul><p></p>	2026-03-30 00:00:00+00	\N	7	f	f	t	f	OPEN	FULL_TIME	e112cf27-d71e-4dfe-9e5f-7603860b5947		3	5	11		11100000	22200000	RANGE	đŸ‘‰ Tuyá»ƒn dá»¥ng Backend Developer (Spring Boot) â€“ Fresher/Junior
\.


--
-- Data for Name: job_ad_candidate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_candidate (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, apply_date, candidate_info_id, candidate_status, eliminate_date, eliminate_reason_detail, eliminate_reason_type, job_ad_id, onboard_date) FROM stdin;
1	2026-03-27 15:45:28.511722+00	Hung@123	t	f	\N	\N	2026-03-27 15:45:28.50695+00	1	APPLIED	\N	\N	\N	1	\N
2	2026-03-27 18:17:53.0066+00	Hung123456	t	f	\N	\N	2026-03-27 18:17:53.002714+00	2	APPLIED	\N	\N	\N	19	\N
3	2026-03-29 16:38:13.405788+00	Uvien@123	t	f	2026-03-29 18:54:24.446153+00	HUngHR123	2026-03-29 16:38:13.401817+00	3	WAITING_ONBOARDING	\N	\N	\N	19	2026-03-30 18:54:00+00
\.


--
-- Data for Name: job_ad_career; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_career (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, career_id, job_ad_id) FROM stdin;
1	\N	seed	t	f	\N	\N	3	1
2	\N	seed	t	f	\N	\N	3	2
3	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	3	18
4	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	3	17
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	4	4
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	4	3
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	5	6
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	5	5
9	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	6	8
10	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	6	7
11	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	7	10
12	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	7	9
13	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	8	12
14	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	8	11
15	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	9	14
16	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	9	13
17	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	10	16
18	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	10	15
19	2026-03-27 17:54:15.670361+00	HUngHR123	t	f	\N	\N	4	19
\.


--
-- Data for Name: job_ad_level; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_level (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, job_ad_id, level_id) FROM stdin;
1	\N	seed	t	f	\N	\N	1	2
2	\N	seed	t	f	\N	\N	2	2
3	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	8	3
4	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	4	3
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	11	4
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	7	4
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	5	4
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	13	5
9	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	9	5
10	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	6	5
11	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	16	6
12	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	12	6
13	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	10	6
14	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	18	7
15	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	15	7
16	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	14	7
17	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	17	8
18	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	3	8
19	2026-03-27 17:54:15.713113+00	HUngHR123	t	f	\N	\N	19	3
\.


--
-- Data for Name: job_ad_process; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_process (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, job_ad_id, name, process_type_id, sort_order) FROM stdin;
1	\N	seed	t	f	\N	\N	1	á»¨ng tuyá»ƒn	3	1
2	\N	seed	t	f	\N	\N	2	á»¨ng tuyá»ƒn	3	1
3	\N	seed	t	f	\N	\N	1	Phá»ng váº¥n	4	2
4	\N	seed	t	f	\N	\N	2	Phá»ng váº¥n	4	2
5	2026-03-27 17:54:15.696096+00	HUngHR123	t	f	\N	\N	19	á»¨ng tuyá»ƒn	3	1
6	2026-03-27 17:54:15.699801+00	HUngHR123	t	f	\N	\N	19	Thi tuyá»ƒn	6	2
7	2026-03-27 17:54:15.701384+00	HUngHR123	t	f	\N	\N	19	Phá»ng váº¥n chuyĂªn mĂ´n	4	3
8	2026-03-27 17:54:15.703566+00	HUngHR123	t	f	\N	\N	19	Phá»ng váº¥n khĂ¡ch hĂ ng	4	4
9	2026-03-27 17:54:15.705188+00	HUngHR123	t	f	\N	\N	19	Onboard	8	5
\.


--
-- Data for Name: job_ad_process_candidate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_process_candidate (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, action_date, is_current_process, job_ad_candidate_id, job_ad_process_id) FROM stdin;
1	2026-03-27 15:45:28.555807+00	Hung@123	t	f	\N	\N	2026-03-27 15:45:28.50695+00	t	1	1
2	2026-03-27 15:45:28.561264+00	Hung@123	t	f	\N	\N	\N	f	1	3
3	2026-03-27 18:17:53.029372+00	Hung123456	t	f	\N	\N	2026-03-27 18:17:53.002714+00	t	2	5
4	2026-03-27 18:17:53.034153+00	Hung123456	t	f	\N	\N	\N	f	2	6
5	2026-03-27 18:17:53.036343+00	Hung123456	t	f	\N	\N	\N	f	2	7
6	2026-03-27 18:17:53.039996+00	Hung123456	t	f	\N	\N	\N	f	2	8
7	2026-03-27 18:17:53.04262+00	Hung123456	t	f	\N	\N	\N	f	2	9
10	2026-03-29 16:38:13.452664+00	Uvien@123	t	f	\N	\N	\N	f	3	7
11	2026-03-29 16:38:13.455296+00	Uvien@123	t	f	\N	\N	\N	f	3	8
8	2026-03-29 16:38:13.442935+00	Uvien@123	t	f	2026-03-29 18:53:57.611591+00	HUngHR123	2026-03-29 16:38:13.401817+00	f	3	5
12	2026-03-29 16:38:13.45774+00	Uvien@123	t	f	2026-03-29 18:54:24.446153+00	HUngHR123	2026-03-29 18:54:24.402807+00	t	3	9
9	2026-03-29 16:38:13.449419+00	Uvien@123	t	f	2026-03-29 18:54:24.447251+00	HUngHR123	2026-03-29 18:53:57.037955+00	f	3	6
\.


--
-- Data for Name: job_ad_statistic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_statistic (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, job_ad_id, view_count) FROM stdin;
2	2026-03-27 17:33:44.918382+00	ANONYMOUS	t	f	\N	\N	4	1
1	2026-03-27 14:30:49.56386+00	ANONYMOUS	t	f	2026-03-28 12:46:25.371384+00	ANONYMOUS	1	24
3	2026-03-27 17:55:44.02404+00	ANONYMOUS	t	f	2026-03-29 19:01:51.596083+00	ANONYMOUS	19	27
\.


--
-- Data for Name: job_ad_work_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad_work_location (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, job_ad_id, work_location_id) FROM stdin;
1	\N	seed	t	f	\N	\N	2	2
2	\N	seed	t	f	\N	\N	1	2
3	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	3	2
4	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	4	2
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	5	2
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	6	2
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	7	2
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	8	2
9	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	9	2
10	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	10	2
11	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	11	2
12	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	12	2
13	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	13	2
14	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	14	2
15	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	15	2
16	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	16	2
17	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	17	2
18	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	18	2
19	2026-03-27 17:54:15.683271+00	HUngHR123	t	f	\N	\N	19	3
\.


--
-- Data for Name: job_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_config (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, description, expression, job_name, schedule_type) FROM stdin;
\.


--
-- Data for Name: level; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.level (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, is_default, name) FROM stdin;
2	\N	seed	t	f	\N	\N	STAFF	t	NhĂ¢n viĂªn
3	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	FRESHER	f	Fresher
4	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	JUNIOR	f	Junior
5	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	MIDDLE	f	Middle
6	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	SENIOR	f	Senior
7	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	LEADER	f	Leader
8	2026-03-27 14:57:37.262207+00	seed	t	f	\N	\N	INTERN	f	Intern
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, cover_photo_id, description, logo_id, name, staff_count_from, staff_count_to, website) FROM stdin;
2	\N	seed	t	f	\N	\N	\N	Demo organization for jobs page	\N	CVConnect Demo Org	\N	\N	https://demo.cvconnect.local
3	2026-03-27 16:27:18.79252+00	HUngHR123	t	f	\N	\N	3	\N	2	BASEVN	1	50	https://base.vn/
\.


--
-- Data for Name: organization_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_address (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, detail_address, district, is_headquarter, org_id, province, ward) FROM stdin;
2	\N	seed	t	f	\N	\N	123 Le Loi	District 1	t	2	Ho Chi Minh	Ben Nghe
3	2026-03-27 16:27:18.853968+00	internal	t	f	\N	\N	466 Ä. La ThĂ nh, Chá»£ Dá»«a, Ă” Chá»£ Dá»«a, HĂ  Ná»™i, Viá»‡t Nam	\N	t	3	ThĂ nh phá»‘ HĂ  Ná»™i	PhÆ°á»ng Ă” Chá»£ Dá»«a
\.


--
-- Data for Name: organization_industry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_industry (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, industry_id, org_id) FROM stdin;
1	2026-03-27 16:27:18.840718+00	internal	t	f	\N	\N	1	3
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."position" (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, department_id, name) FROM stdin;
2	\N	seed	t	f	\N	\N	BE_DEV	2	Backend Developer
5	2026-03-27 17:48:14.639073+00	HUngHR123	t	f	2026-03-27 17:49:12.002023+00	HUngHR123	1122	3	BE_thiet ke nghiep vu 
\.


--
-- Data for Name: position_process; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.position_process (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, name, position_id, process_type_id, sort_order) FROM stdin;
1	2026-03-27 17:48:14.660779+00	HUngHR123	t	f	\N	\N	á»¨ng tuyá»ƒn	5	3	1
2	2026-03-27 17:48:14.670686+00	HUngHR123	t	f	\N	\N	Thi tuyá»ƒn	5	6	2
3	2026-03-27 17:48:14.674758+00	HUngHR123	t	f	\N	\N	Phá»ng váº¥n chuyĂªn mĂ´n	5	4	3
4	2026-03-27 17:48:14.679677+00	HUngHR123	t	f	\N	\N	Phá»ng váº¥n khĂ¡ch hĂ ng	5	4	4
5	2026-03-27 17:48:14.683413+00	HUngHR123	t	f	\N	\N	Onboard	5	8	5
\.


--
-- Data for Name: process_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.process_type (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, code, is_default, name, sort_order) FROM stdin;
3	\N	seed	t	f	\N	\N	APPLY	t	á»¨ng tuyá»ƒn	1
4	\N	seed	t	f	\N	\N	INTERVIEW	t	Phá»ng váº¥n	4
5	\N	admin	t	f	\N	\N	SCAN_CV	t	Lá»c há»“ sÆ¡	2
6	\N	admin	t	f	\N	\N	CONTEST	t	Thi tuyá»ƒn	3
7	\N	admin	t	f	\N	\N	OFFER	t	Äá» nghá»‹ lĂ m viá»‡c	5
8	\N	admin	t	f	\N	\N	ONBOARD	t	Onboard	6
\.


--
-- Data for Name: search_history_outside; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.search_history_outside (id, created_at, created_by, is_active, is_deleted, updated_at, updated_by, keyword, user_id) FROM stdin;
\.


--
-- Name: attach_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attach_file_id_seq', 5, true);


--
-- Name: calendar_candidate_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calendar_candidate_info_id_seq', 1, true);


--
-- Name: calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calendar_id_seq', 1, true);


--
-- Name: candidate_evaluation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.candidate_evaluation_id_seq', 1, true);


--
-- Name: candidate_info_apply_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.candidate_info_apply_id_seq', 3, true);


--
-- Name: candidate_summary_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.candidate_summary_org_id_seq', 1, true);


--
-- Name: careers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.careers_id_seq', 10, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_id_seq', 4, true);


--
-- Name: failed_rollback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_rollback_id_seq', 1, false);


--
-- Name: industry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industry_id_seq', 26, true);


--
-- Name: interview_panel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.interview_panel_id_seq', 1, true);


--
-- Name: job_ad_candidate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_candidate_id_seq', 3, true);


--
-- Name: job_ad_career_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_career_id_seq', 19, true);


--
-- Name: job_ad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_id_seq', 19, true);


--
-- Name: job_ad_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_level_id_seq', 19, true);


--
-- Name: job_ad_process_candidate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_process_candidate_id_seq', 12, true);


--
-- Name: job_ad_process_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_process_id_seq', 9, true);


--
-- Name: job_ad_statistic_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_statistic_id_seq', 3, true);


--
-- Name: job_ad_work_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_work_location_id_seq', 19, true);


--
-- Name: job_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_config_id_seq', 1, false);


--
-- Name: level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.level_id_seq', 8, true);


--
-- Name: organization_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_address_id_seq', 3, true);


--
-- Name: organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_id_seq', 3, true);


--
-- Name: organization_industry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_industry_id_seq', 1, true);


--
-- Name: position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_id_seq', 5, true);


--
-- Name: position_process_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_process_id_seq', 5, true);


--
-- Name: process_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.process_type_id_seq', 8, true);


--
-- Name: search_history_outside_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.search_history_outside_id_seq', 1, false);


--
-- Name: attach_file attach_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attach_file
    ADD CONSTRAINT attach_file_pkey PRIMARY KEY (id);


--
-- Name: calendar_candidate_info calendar_candidate_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_candidate_info
    ADD CONSTRAINT calendar_candidate_info_pkey PRIMARY KEY (id);


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (id);


--
-- Name: candidate_evaluation candidate_evaluation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_evaluation
    ADD CONSTRAINT candidate_evaluation_pkey PRIMARY KEY (id);


--
-- Name: candidate_info_apply candidate_info_apply_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_info_apply
    ADD CONSTRAINT candidate_info_apply_pkey PRIMARY KEY (id);


--
-- Name: candidate_summary_org candidate_summary_org_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_summary_org
    ADD CONSTRAINT candidate_summary_org_pkey PRIMARY KEY (id);


--
-- Name: careers careers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.careers
    ADD CONSTRAINT careers_pkey PRIMARY KEY (id);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: failed_rollback failed_rollback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_rollback
    ADD CONSTRAINT failed_rollback_pkey PRIMARY KEY (id);


--
-- Name: industry industry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry
    ADD CONSTRAINT industry_pkey PRIMARY KEY (id);


--
-- Name: interview_panel interview_panel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interview_panel
    ADD CONSTRAINT interview_panel_pkey PRIMARY KEY (id);


--
-- Name: job_ad_candidate job_ad_candidate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_candidate
    ADD CONSTRAINT job_ad_candidate_pkey PRIMARY KEY (id);


--
-- Name: job_ad_career job_ad_career_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_career
    ADD CONSTRAINT job_ad_career_pkey PRIMARY KEY (id);


--
-- Name: job_ad_level job_ad_level_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_level
    ADD CONSTRAINT job_ad_level_pkey PRIMARY KEY (id);


--
-- Name: job_ad job_ad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT job_ad_pkey PRIMARY KEY (id);


--
-- Name: job_ad_process_candidate job_ad_process_candidate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_process_candidate
    ADD CONSTRAINT job_ad_process_candidate_pkey PRIMARY KEY (id);


--
-- Name: job_ad_process job_ad_process_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_process
    ADD CONSTRAINT job_ad_process_pkey PRIMARY KEY (id);


--
-- Name: job_ad_statistic job_ad_statistic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_statistic
    ADD CONSTRAINT job_ad_statistic_pkey PRIMARY KEY (id);


--
-- Name: job_ad_work_location job_ad_work_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad_work_location
    ADD CONSTRAINT job_ad_work_location_pkey PRIMARY KEY (id);


--
-- Name: job_config job_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_config
    ADD CONSTRAINT job_config_pkey PRIMARY KEY (id);


--
-- Name: level level_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level
    ADD CONSTRAINT level_pkey PRIMARY KEY (id);


--
-- Name: organization_address organization_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_address
    ADD CONSTRAINT organization_address_pkey PRIMARY KEY (id);


--
-- Name: organization_industry organization_industry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_industry
    ADD CONSTRAINT organization_industry_pkey PRIMARY KEY (id);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: position position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (id);


--
-- Name: position_process position_process_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.position_process
    ADD CONSTRAINT position_process_pkey PRIMARY KEY (id);


--
-- Name: process_type process_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.process_type
    ADD CONSTRAINT process_type_pkey PRIMARY KEY (id);


--
-- Name: search_history_outside search_history_outside_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.search_history_outside
    ADD CONSTRAINT search_history_outside_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict rWMYT8mqI1GVkplEjzT721KFJPeDxCFrHaXn1geWQedoL2NdYSiFOhCruXVMg8T

