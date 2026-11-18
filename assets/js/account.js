import { supabase } from "./supabase-client.js";

const pages = [
  ["Inicio","/Web-Publica-Nova/"],["Nova Apps","/Web-Publica-Nova/nova-apps/"],
  ["Nova E-commerce","/Web-Publica-Nova/nova-ecommerce/"],["Nova Bank","/Web-Publica-Nova/nova-bank/"],
  ["Nova Novels","/Web-Publica-Nova/nova-novels/"],["Nova Nexus","/Web-Publica-Nova/nova-nexus/"],
  ["Noticias Nova","/Web-Publica-Nova/noticias-nova/"],["Nova Chat","/Web-Publica-Nova/nova-chat/"],
  ["Multimedia Nova","/Web-Publica-Nova/multimedia-nova/"],["Nova IA","/Web-Publica-Nova/nova-ia/"],
  ["Fútbol Nova","/Web-Publica-Nova/futbol-nova/"]
];
const style=document.createElement("style");
style.textContent=`
.nova-account{position:relative;z-index:11;display:flex;align-items:center;gap:8px;flex:0 0 auto;margin-left:auto}
.nova-account-btn{width:44px;height:44px;border-radius:50%;border:1px solid var(--cyan,#45d5df);background:var(--panel2,#14243a);color:var(--text,#edf4ff);display:grid;place-items:center;font-size:1.15rem;cursor:pointer}
.nova-account-btn img{width:100%;height:100%;object-fit:cover;border-radius:50%}
.nova-account-panel{position:absolute;z-index:1200;right:0;top:calc(100% + 10px);width:min(390px,calc(100vw - 28px));max-height:min(78vh,720px);overflow:auto;padding:16px;border:1px solid var(--line,#263b56);border-radius:18px;background:#101d30;color:#edf4ff;box-shadow:0 18px 60px #000b}
.nova-account-panel[hidden]{display:none}
.nova-menu-section{padding:10px 0;border-bottom:1px solid #2b405d}.nova-menu-section:last-child{border:0}
.nova-menu-title{margin:0 0 8px;color:#8fdde8;font-size:.76rem;letter-spacing:.1em;text-transform:uppercase}
.nova-menu-links{display:grid;grid-template-columns:1fr 1fr;gap:6px}
.nova-menu-links a,.nova-menu-action{display:flex;align-items:center;min-height:38px;padding:8px 10px;border:1px solid #2b405d;border-radius:10px;background:#14243a;color:#edf4ff;text-decoration:none;font:inherit;font-size:.9rem;text-align:left}
.nova-menu-links a[aria-current=page]{border-color:#45d5df;color:#7fe7ee}
.nova-account-panel label{display:block;margin:10px 0 5px;color:#a8b8ce}
.nova-account-panel input{width:100%;padding:10px;border:1px solid #405776;border-radius:10px;background:#08111f;color:#edf4ff}
.nova-account-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}
.nova-account-actions button,.nova-menu-action{border:0;border-radius:10px;padding:10px 12px;background:#6558e8;color:white;font-weight:750;cursor:pointer}
.nova-account-actions .secondary{background:#253957;border:1px solid #49638c}
.nova-account-status{font-size:.88rem;color:#9ee5c0;white-space:pre-wrap}
.nova-account-summary{color:#a8b8ce;font-size:.9rem;overflow-wrap:anywhere}
.nova-theme-row{display:flex;align-items:center;justify-content:space-between;gap:10px}
.nova-theme-row button{padding:8px 11px;border-radius:10px;border:1px solid #49638c;background:#253957;color:#fff}
body.nova-light{color-scheme:light;--bg:#f1f5fb;--panel:#fff;--panel2:#e5edf7;--text:#14243a;--muted:#52647c;--line:#cbd7e6;background:#f1f5fb;color:#14243a}
body.nova-light header{background:#ffffffed}
body.nova-light .card,body.nova-light .panel,body.nova-light .section-nav{background:#fff;color:#14243a}
body.nova-light .nova-account-panel{background:#fff;color:#14243a;border-color:#cbd7e6}
body.nova-light .nova-menu-links a,body.nova-light .nova-menu-action{background:#edf3fa;color:#14243a;border-color:#cbd7e6}
body.nova-light .nova-account-panel input{background:#f6f8fc;color:#14243a;border-color:#cbd7e6}
`;
document.head.append(style);
const host=document.createElement("div");host.className="nova-account";
host.innerHTML=`<button class="nova-account-btn" type="button" aria-label="Abrir menú NOVA" title="Menú y cuenta">♙</button>
<section class="nova-account-panel" hidden aria-label="Menú y cuenta NOVA">
<div class="nova-menu-section"><h2 class="nova-menu-title">Cuenta de usuario</h2><p class="nova-account-summary">Comprueba tu sesión.</p>
<div class="nova-account-login" hidden><div class="nova-account-actions"><button type="button" class="nova-account-google">Iniciar sesión con Google</button></div></div>
<div class="nova-account-form" hidden><label for="nova-account-name">Nombre visible</label><input id="nova-account-name" maxlength="80" autocomplete="nickname">
<label for="nova-account-avatar">URL de imagen de perfil</label><input id="nova-account-avatar" type="url" maxlength="500" placeholder="https://…">
<div class="nova-account-actions"><button type="button" class="nova-account-save">Guardar cuenta</button><button type="button" class="secondary nova-account-logout">Cerrar sesión</button></div></div>
<p class="nova-account-status" role="status"></p></div>
<div class="nova-menu-section"><h3 class="nova-menu-title">Ajustes de esta página</h3><div class="nova-theme-row"><span>Modo de apariencia</span><button type="button" class="nova-theme-toggle">🌙 Modo oscuro</button></div></div>
<div class="nova-menu-section"><h3 class="nova-menu-title">Otras páginas NOVA</h3><nav class="nova-menu-links" aria-label="Otras páginas NOVA"></nav></div>
<div class="nova-menu-section"><h3 class="nova-menu-title">Ecosistema y apoyo</h3><div class="nova-menu-links"><a href="/Web-Publica-Nova/#donaciones">Donaciones</a><a href="https://github.com/Cumba35/Web-Publica-Nova">Código público</a><a href="/Web-Publica-Nova/nova-nexus/">Eventos y novedades</a></div></div>
</section>`;
const bar=document.querySelector("header .bar")||document.querySelector("body > header")||document.querySelector("body > main")||document.body;if(bar)bar.append(host);
const button=host.querySelector(".nova-account-btn"),panel=host.querySelector(".nova-account-panel"),summary=host.querySelector(".nova-account-summary"),form=host.querySelector(".nova-account-form"),login=host.querySelector(".nova-account-login"),status=host.querySelector(".nova-account-status"),nameInput=host.querySelector("#nova-account-name"),avatarInput=host.querySelector("#nova-account-avatar");
panel.id="nova-account-panel";button.setAttribute("aria-controls",panel.id);button.setAttribute("aria-expanded","false");
function setPanelOpen(open){panel.hidden=!open;button.setAttribute("aria-expanded",String(open));}
const pageNav=host.querySelector(".nova-menu-links[aria-label]");pages.forEach(([label,url])=>{const a=document.createElement("a");a.href=url;a.textContent=label;if(location.pathname.replace(/\/$/,"")===url.replace(/\/$/,""))a.setAttribute("aria-current","page");pageNav.append(a);});
function currentPageReturnUrl(){const u=new URL(location.href);["code","error","error_code","error_description","access_token","refresh_token","type"].forEach(k=>u.searchParams.delete(k));return u.href;}
function paint(session){const user=session?.user||null,meta=user?.user_metadata||{};button.textContent=user?(meta.full_name||meta.name||user.email||"U").trim().slice(0,1).toUpperCase():"♙";button.setAttribute("aria-label",user?"Abrir menú y cuenta de usuario":"Abrir menú e iniciar sesión");summary.textContent=user?(user.email||"Sesión iniciada"):"Inicia sesión para acceder a las funciones de tu cuenta.";form.hidden=!user;login.hidden=!!user;if(user){nameInput.value=meta.full_name||meta.name||"";avatarInput.value=meta.avatar_url||meta.picture||"";const avatar=meta.avatar_url||meta.picture;if(avatar&&/^https:\/\//i.test(avatar)){button.replaceChildren();const img=document.createElement("img");img.src=avatar;img.alt="";button.append(img);}}}
async function refresh(){const {data,error}=await supabase.auth.getSession();if(error)status.textContent=error.message;paint(data?.session);}
button.addEventListener("click",()=>setPanelOpen(panel.hidden));
const themeButton=host.querySelector(".nova-theme-toggle");
function readSavedTheme(){try{return localStorage.getItem("nova-theme");}catch{return null;}}
function saveTheme(theme){try{localStorage.setItem("nova-theme",theme);}catch{/* Theme still works for this page if storage is unavailable. */}}
function applyTheme(theme){const light=theme==="light";document.body.classList.toggle("nova-light",light);themeButton.textContent=light?"🌙 Cambiar a modo oscuro":"☀️ Cambiar a modo claro";themeButton.setAttribute("aria-pressed",String(light));}
themeButton.addEventListener("click",()=>{const next=document.body.classList.contains("nova-light")?"dark":"light";saveTheme(next);applyTheme(next);});
applyTheme(readSavedTheme()||"dark");
host.querySelector(".nova-account-google").addEventListener("click",async()=>{status.textContent="Abriendo Google…";const {error}=await supabase.auth.signInWithOAuth({provider:"google",options:{redirectTo:currentPageReturnUrl(),queryParams:{prompt:"select_account"}}});if(error)status.textContent=error.message;});
host.querySelector(".nova-account-save").addEventListener("click",async()=>{const displayName=nameInput.value.trim(),avatarUrl=avatarInput.value.trim();if(avatarUrl&&!/^https:\/\//i.test(avatarUrl)){status.textContent="La imagen debe usar HTTPS.";return;}const {data,error}=await supabase.auth.updateUser({data:{full_name:displayName,avatar_url:avatarUrl||null}});if(error){status.textContent=error.message;return;}paint({user:data.user});status.textContent="Cuenta actualizada.";});
host.querySelector(".nova-account-logout").addEventListener("click",async()=>{const {error}=await supabase.auth.signOut();status.textContent=error?error.message:"Sesión cerrada.";if(!error)paint(null);});
supabase.auth.onAuthStateChange((_event,session)=>{paint(session);if(session&&new URLSearchParams(location.search).has("code")){const u=new URL(location.href);u.searchParams.delete("code");history.replaceState({},document.title,u.pathname+u.search+u.hash);}});
refresh().catch(e=>{status.textContent=e.message;});
document.addEventListener("click",e=>{if(!host.contains(e.target))setPanelOpen(false);});
document.addEventListener("keydown",e=>{if(e.key==="Escape"&&!panel.hidden){setPanelOpen(false);button.focus();}});
