-- public.google_metadata definition

-- Drop table
CREATE INDEX google_metadata_assets_match_index on assets using GIN ("deviceAssetId" gin_trgm_ops );

DROP TABLE public.google_metadata;

CREATE TABLE public.google_metadata (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	title varchar NOT NULL,
	path varchar not null,
	creation_date int8 NULL,
	taken_date int8 NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	altitude float8 NULL,
	latitude_exif float8 NULL,
	longitude_exif float8 NULL,
	altitude_exif float8 NULL,
	processed bool NULL,
	asset_id uuid NULL,
	asset_ids varchar default '',
	album varchar null,
	score float8 DEFAULT 0 NOT NULL,
	nb_matches int4 DEFAULT 0 NOT NULL,
	CONSTRAINT google_metadata_pk PRIMARY KEY (id)
);
CREATE INDEX google_metadata_google_match_index on google_metadata using GIN (title gin_trgm_ops );


DO $$
declare 
	cpt integer := 0;
	metadata record;
begin 
	for metadata in 
		SELECT
		    a.id as asset_id,
			a."deviceAssetId" as filename,
		    gm.title,
			gm.id,
		    a."originalPath",
		    similarity(a."deviceAssetId", gm.title) AS score
		FROM
		    assets a
		INNER JOIN 
		    google_metadata gm ON a."deviceAssetId" % gm.title
		WHERE
		    similarity(a."deviceAssetId", gm.title) > 0.8
			and gm.processed = false
    LOOP
        RAISE NOTICE '[%] filename: %, title: %, score: %',
                     cpt, metadata.filename, metadata.title, metadata.score;
		UPDATE google_metadata
		set asset_id = metadata.asset_id,
		    score = metadata.score
		where id = metadata.id
		and score < metadata.score;
		UPDATE google_metadata set processed = true, nb_matches = nb_matches +1, asset_ids = metadata.asset_id || ',' || asset_ids where id = metadata.id;
        cpt := cpt + 1;	
    END LOOP;
end;
$$;

-- Finish
CLOSE mycursor;
COMMIT;

-- Migrate latitude		
update exif e
set longitude = gm.longitude,
	latitude = gm.latitude
from google_metadata gm 
where e."assetId" = gm.asset_id
and gm.nb_matches = 1 and gm.score > 0 and gm.latitude is not null and  e.longitude is null and e.longitude != 0;

select * from exif where city is not null;


update google_metadata set album = regexp_replace(path, '/.*/([^/]+)/([^/]+)$', '\1'); 


insert into albums_assets_assets ("albumsId" , "assetsId" , "createdAt" )
select distinct a.id, origin."id",  origin."localDateTime"
from assets origin
inner join assets google on google."duplicateId" = origin."duplicateId" and origin."originalPath" not like '/mnt/nanopi/data/nextcloud/shared/photos/media/zuliz/Google Photos/%' and google."originalPath" like '/mnt/nanopi/data/nextcloud/shared/photos/media/zuliz/Google Photos/%'
inner join albums a on a."albumName" =  regexp_replace(google."originalPath", '/.*/([^/]+)/([^/]+)$', '\1')


update assets google
set "duplicateId" = null,
    "status" = 'trashed',
    "deletedAt" = now()
where google."duplicateId" in (select origin."duplicateId" from assets origin where origin."originalPath" not like '/mnt/nanopi/data/nextcloud/shared/photos/media/zuliz/Google Photos/%' )
and google."originalPath"  like '/mnt/nanopi/data/nextcloud/shared/photos/media/zuliz/Google Photos/%'



