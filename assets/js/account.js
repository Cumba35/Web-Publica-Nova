import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";

const SUPABASE_URL = "https://suirbghmnuxixktzkrze.supabase.co";
const SUPABASE_KEY = "sb_publishable_1ZmYJ5J-A8hGDIcUIOiY3g_dYOKdnIp";
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true, flowType: "pkce" }
});

const style = document.createElement("style");
style.textContent = `
.nova-account{margin-left:auto;display:flex;align-items:center;gap:8px;flex:0 0 auto}
.nova-account-btn{width:42px;height:42px;border-radius:50%;border:1px solid var(--cyan,#45d5df);background:var(--panel2,#14243a);color:var(--text,#edf4ff);display:grid;place-items:center;font-size:1.15rem;cursor:pointer}
.nova-account-btn img{width:100%;height:100%;object-fit:cover;border-radius:50%}
.nova-account-panel{position:fixed;z-index:1000;right:14px;top:76px;width:min(390px,calc(100vw - 28px));max-height:calc(100vh - 96px);overflow:auto;padding:18px;border:1px solid var(--line,#263b56);border-radius:18px;background:#101d30;color:#edf4ff;box-shadow:0 18px 60px #0009}
.nova-account-panel[hidden]{display:none}.nova-account-panel label{display:block;margin:12px 0 5px;color:#a8b8ce}.nova-account-panel input{width:100%;padding:11px;border:1px solid #405776;border-radius:10px;background:#08111f;color:#edf4ff}
.nova-account-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:14px}.nova-account-actions button{border:0;border-radius:10px;padding:10px 13px;background:#6558e8;color:white;font-weight:750;cursor:pointer}.nova-account-actions .secondary{background:#253957;border:1px solid #49638c}.nova-account-status{font-size:.9rem;color:#9ee5c0;white-space:pre-wrap}
`;
document.head.append(style);

const host = document.createElement("div");
host.className = "nova-account";
host.innerHTML = `<button class="nova-account-btn" type="button" aria-label="Iniciar sesión" title="Iniciar sesión">♙</button>
<section class="nova-account-panel" hidden aria-label="Cuenta NOVA">
<h2 style="margin-top:0">Cuenta NOVA</h2><p class="nova-account-summary">Comprueba tu sesión.</p>
<div class="nova-account-form" hidden>
<label for="nova-account-name">Nombre visible</label><input id="nova-account-name" maxlength="80" autocomplete="nickname">
<label for="nova-account-avatar">URL de imagen de perfil (opcional)</label><input id="nova-account-avatar" type="url" maxlength="500" placeholder="https://…">
<div class="nova-account-actions"><button type="button" class="nova-account-save">Guardar perfil</button><button type="button" class="secondary nova-account-logout">Cerrar sesión</button></div>
</div>
<div class="nova-account-login" hidden><div class="nova-account-actions"><button type="button" class="nova-account-google">Continuar con Google</button></div></div>
<p class="nova-account-status" role="status"></p>
</section>`;
const bar = document.querySelector("header .bar") || document.querySelector("body > header");
if (bar) bar.append(host);

const button = host.querySelector(".nova-account-btn");
const panel = host.querySelector(".nova-account-panel");
const summary = host.querySelector(".nova-account-summary");
const form = host.querySelector(".nova-account-form");
const login = host.querySelector(".nova-account-login");
const status = host.querySelector(".nova-account-status");
const nameInput = host.querySelector("#nova-account-name");
const avatarInput = host.querySelector("#nova-account-avatar");
let activeUser = null;

function paint(session) {
  activeUser = session?.user || null;
  const metadata = activeUser?.user_metadata || {};
  button.textContent = activeUser ? (metadata.full_name || metadata.name || activeUser.email || "U").trim().slice(0,1).toUpperCase() : "♙";
  button.setAttribute("aria-label", activeUser ? "Abrir perfil de usuario" : "Iniciar sesión");
  button.title = activeUser ? "Mi cuenta" : "Iniciar sesión";
  summary.textContent = activeUser ? (activeUser.email || "Sesión activa") : "Inicia sesión sin salir de esta página. Al volver del proveedor se conservará esta dirección.";
  form.hidden = !activeUser;
  login.hidden = !!activeUser;
  if (activeUser) {
    nameInput.value = metadata.full_name || metadata.name || "";
    avatarInput.value = metadata.avatar_url || metadata.picture || "";
    const avatar = metadata.avatar_url || metadata.picture;
    if (avatar && /^https:\/\//i.test(avatar)) {
      button.replaceChildren();
      const img = document.createElement("img"); img.src = avatar; img.alt = ""; button.append(img);
    } else button.textContent = (metadata.full_name || metadata.name || activeUser.email || "U").trim().slice(0,1).toUpperCase();
  }
}
async function refresh() {
  const { data, error } = await supabase.auth.getSession();
  if (error) status.textContent = error.message;
  paint(data?.session);
}
button.addEventListener("click", () => { panel.hidden = !panel.hidden; });
host.querySelector(".nova-account-google").addEventListener("click", async () => {
  status.textContent = "Abriendo Google…";
  const { error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo: window.location.href, queryParams: { prompt: "select_account" } }
  });
  if (error) status.textContent = error.message;
});
host.querySelector(".nova-account-save").addEventListener("click", async () => {
  const displayName = nameInput.value.trim();
  const avatarUrl = avatarInput.value.trim();
  if (avatarUrl && !/^https:\/\//i.test(avatarUrl)) { status.textContent = "La imagen debe usar HTTPS."; return; }
  const { data, error } = await supabase.auth.updateUser({ data: { full_name: displayName, avatar_url: avatarUrl || null } });
  if (error) { status.textContent = error.message; return; }
  paint({ user: data.user }); status.textContent = "Perfil actualizado.";
});
host.querySelector(".nova-account-logout").addEventListener("click", async () => {
  const { error } = await supabase.auth.signOut();
  status.textContent = error ? error.message : "Sesión cerrada.";
  if (!error) paint(null);
});
supabase.auth.onAuthStateChange((_event, session) => paint(session));
refresh().catch(error => { status.textContent = error.message; });
document.addEventListener("click", event => { if (!host.contains(event.target)) panel.hidden = true; });
