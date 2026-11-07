/* ==========================================================
   Wealth's Tech: shared settings for index.html and admin.html

   1. Create a free project at https://supabase.com
   2. Run supabase-setup.sql in its SQL Editor (one time)
   3. Project Settings > API: copy the Project URL and the anon / publishable key below.

   The anon key is MEANT to be public (it is visible in any website's code).
   It is safe because Row Level Security (set up by the SQL file) only lets
   visitors READ the list of sites. Only the logged-in admin can add, edit or delete.
   NEVER paste the "service_role" or "secret" key here.
   ========================================================== */
window.WT_CONFIG = {
  SUPABASE_URL: "",        /* e.g. "https://abcdxyz.supabase.co" */
  SUPABASE_ANON_KEY: ""    /* the long anon / publishable key */
};
