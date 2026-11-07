(() => {
  const grid = document.getElementById('portfolio-grid');
  const dialog = document.getElementById('external-notice');
  if (!grid || !dialog) return;
  const config = window.SUPABASE_CONFIG || {};
  let pendingUrl = '';
  const safeUrl = value => {
    try { const u = new URL(value); return ['https:','http:'].includes(u.protocol) ? u : null; }
    catch { return null; }
  };
  const el = (tag, cls, text) => { const n=document.createElement(tag); if(cls)n.className=cls; if(text!==undefined)n.textContent=text; return n; };
  function showNotice(url) {
    const parsed=safeUrl(url); if(!parsed)return;
    pendingUrl=parsed.href;
    document.getElementById('notice-url').textContent=parsed.href;
    if(typeof dialog.showModal==='function') dialog.showModal();
    else if(confirm('You are leaving this website for '+parsed.href+'. Continue?')) window.open(parsed.href,'_blank','noopener,noreferrer');
  }
  document.getElementById('notice-cancel').addEventListener('click',()=>dialog.close());
  document.getElementById('notice-continue').addEventListener('click',()=>{
    if(pendingUrl) window.open(pendingUrl,'_blank','noopener,noreferrer');
    dialog.close(); pendingUrl='';
  });
  dialog.addEventListener('click',e=>{if(e.target===dialog)dialog.close();});
  function render(projects) {
    grid.replaceChildren();
    if(!projects.length){grid.append(el('div','portfolio-empty','Our latest projects will appear here soon.'));return;}
    projects.forEach(project=>{
      const card=el('article','portfolio-card');
      if(project.image_url){const img=el('img','portfolio-thumb');img.src=project.image_url;img.alt=project.title+' website preview';img.loading='lazy';img.onerror=()=>img.replaceWith(el('div','portfolio-thumb-placeholder',project.title.slice(0,1).toUpperCase()));card.append(img);}
      else card.append(el('div','portfolio-thumb-placeholder',project.title.slice(0,1).toUpperCase()));
      const body=el('div','portfolio-body');body.append(el('h3','',project.title));body.append(el('p','',project.description||'A website designed and developed by our team.'));
      const link=el('a','portfolio-link','Visit website ');link.href='#';link.append(el('span','','↗'));link.addEventListener('click',e=>{e.preventDefault();showNotice(project.live_url);});body.append(link);card.append(body);grid.append(card);
    });
  }
  async function load() {
    if(!window.supabase || !config.url || !config.anonKey || config.url.includes('YOUR_')) {
      grid.replaceChildren(el('div','portfolio-empty','Our project showcase is being set up. Check back soon.'));return;
    }
    try {
      const client=window.supabase.createClient(config.url,config.anonKey);
      const {data,error}=await client.from('portfolio_projects').select('id,title,description,live_url,image_url,created_at').eq('is_published',true).order('sort_order',{ascending:true}).order('created_at',{ascending:false});
      if(error)throw error; render(data||[]);
    } catch(err) { console.error('Portfolio could not load:',err);grid.replaceChildren(el('div','portfolio-empty','Projects are temporarily unavailable. Please try again later.')); }
  }
  load();
})();
