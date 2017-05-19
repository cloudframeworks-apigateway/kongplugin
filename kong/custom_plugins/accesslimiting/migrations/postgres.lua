return {
    {
        name = "2016-12-09-132400_init_accesslimiting",
        up = [[
            CREATE TABLE IF NOT EXISTS accesslimiting_blacklist(
                api_id uuid,
                ip varchar(40) NOT NULL,
                PRIMARY KEY (api_id, ip)
            );


            CREATE TABLE IF NOT EXISTS accesslimiting_record(
                api_id uuid,
                ip varchar(40) NOT NULL,
                created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc')
            );

            DO $$
            BEGIN
                IF (SELECT to_regclass('accesslimiting_record_idx')) IS NULL THEN
                    CREATE INDEX accesslimiting_record_idx ON accesslimiting_record(created_at);
                END IF;
                TRUNCATE TABLE accesslimiting_record;
            END$$;
        ]],
        down = [[
            DROP TABLE accesslimiting_blacklist;
            DROP TABLE accesslimiting_record;
        ]]
    }
}
