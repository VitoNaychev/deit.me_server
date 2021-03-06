CREATE TYPE gender AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE preference AS ENUM ('MEN', 'WOMEN', 'BOTH');

CREATE TABLE public.user
(
    id serial NOT NULL,
    email varchar(50) NOT NULL,
    password varchar(80) NOT NULL,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    phone_number varchar(50) NOT NULL,
	gender GENDER NOT NULL,
	preference PREFERENCE NOT NULL,
	description text,
	liked_profiles integer NOT NULL DEFAULT 0,
	
	UNIQUE(email),
	PRIMARY KEY (id)
);

CREATE TABLE public.hobby
(
    id serial NOT NULL,
    hobby varchar(50) NOT NULL,
    
	UNIQUE(hobby),
	PRIMARY KEY (id)
);

CREATE TABLE public.user_hobby
(
	user_id integer NOT NULL,
	hobby_id integer NOT NULL,
    FOREIGN KEY (user_id)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	FOREIGN KEY (hobby_id)
        REFERENCES public.hobby (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
    
	PRIMARY KEY (user_id, hobby_id)
);

CREATE TABLE public.picture
(
	id serial NOT NULL,
	picture bytea NOT NULL,
	type varchar(50) NOT NULL,
	user_id integer NOT NULL,
	FOREIGN KEY (user_id)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	
	PRIMARY KEY (id)
);

CREATE TABLE public.like
(
	id serial NOT NULL,
	liking_user integer NOT NULL,
	liked_user integer NOT NULL,
	FOREIGN KEY (liking_user)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	FOREIGN KEY (liked_user)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	
	PRIMARY KEY (id)
);

CREATE TABLE public.match
(
	id serial NOT NULL,
	user_one integer NOT NULL,
	user_two integer NOT NULL,
	FOREIGN KEY (user_one)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	FOREIGN KEY (user_two)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	
	PRIMARY KEY (id)
);

CREATE TABLE public.message
(
	id serial NOT NULL,
	match_id integer NOT NULL,
	user_id integer NOT NULL,
	content text NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	FOREIGN KEY (match_id)
        REFERENCES public.match (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
	FOREIGN KEY (user_id)
        REFERENCES public.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,

	PRIMARY KEY (id)
);

-- Match trigger has to add duplicate records for user_one and user_two
-- aka if user 5 likes user 7 there should be two records:
--
-- user_one | user_two
-- -------------------
--    5     |    7
--    7     |    5
--
-- This in turn will give us an array in the server layer with the people
-- our user has matched with, without the need of any extra logic