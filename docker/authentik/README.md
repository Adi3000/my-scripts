Drop index on enabled filter, it allow faster connection on low number of authentication flow :
```sql
DROP INDEX authentik_c_enabled_d72365_idx ON public.authentik_core_source 
```

(index was based on this source code)
```
CREATE INDEX authentik_c_enabled_d72365_idx ON public.authentik_core_source USING btree (enabled)
```
