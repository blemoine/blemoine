# Tips 

## Docker

### Clean all images and container

```
  docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
  docker rmi $(docker images -a -q)
```


## Git

### Delete stale branches

```
git branch | grep -v '^*' | xargs git branch -d
```

## Find

### Find something in all `src`s directories

```
find */src -type f -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/coverage/*' | xargs grep -sl 'console.log'
```

## Postgres

### Find missing Foreign Key Indexes

```
SELECT c.conrelid::regclass AS "table",
       /* list of key column names in order */
       string_agg(a.attname, ',' ORDER BY x.n) AS columns,
       pg_catalog.pg_size_pretty(
          pg_catalog.pg_relation_size(c.conrelid)
       ) AS size,
       c.conname AS constraint,
       c.confrelid::regclass AS referenced_table
FROM pg_catalog.pg_constraint c
   /* enumerated key column numbers per foreign key */
   CROSS JOIN LATERAL
      unnest(c.conkey) WITH ORDINALITY AS x(attnum, n)
   /* name for each key column */
   JOIN pg_catalog.pg_attribute a
      ON a.attnum = x.attnum
         AND a.attrelid = c.conrelid
WHERE NOT EXISTS
        /* is there a matching index for the constraint? */
        (SELECT 1 FROM pg_catalog.pg_index i
         WHERE i.indrelid = c.conrelid
           /* the first index columns must be the same as the
              key columns, but order doesn't matter */
           AND (i.indkey::smallint[])[0:cardinality(c.conkey)-1]
               @> c.conkey)
  AND c.contype = 'f'
GROUP BY c.conrelid, c.conname, c.confrelid
ORDER BY pg_catalog.pg_relation_size(c.conrelid) DESC;
```

### Find unused indexes

```
SELECT s.schemaname,
       s.relname AS tablename,
       s.indexrelname AS indexname,
       pg_relation_size(s.indexrelid) AS index_size
FROM pg_catalog.pg_stat_user_indexes s
   JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan = 0      -- has never been scanned
  AND 0 <>ALL (i.indkey)  -- no index column is an expression
  AND NOT i.indisunique   -- is not a UNIQUE index
  AND NOT EXISTS          -- does not enforce a constraint
         (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;
```

## Security

### Encoding / Decoding

```
function plouf() {
 PASS="$(/usr/local/bin/pwgen -cnsB 16 1)"
 ENC="$(openssl enc -aes-256-cbc -salt -a -pass pass:$PASS -in $1)"
 echo "Password: $PASS"
 unplouf $ENC
}

function unplouf() {
  UNPLOUF="openssl enc -aes-256-cbc -d -a << EOF\n$1\nEOF"
  echo $UNPLOUF
 echo "$UNPLOUF" | pbcopy
}
```

## React

### Track changes

```
function useLogIfChanged<T>(name: string, value: T) {
  const previous = useRef(value);
  if (!Object.is(previous.current, value)) {
    // eslint-disable-next-line no-console
    console.log(`${name} changed. Old:`, previous.current, "New:", value);
    previous.current = value;
  }
}
```
