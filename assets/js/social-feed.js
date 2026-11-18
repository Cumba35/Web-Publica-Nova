import { supabase } from "./supabase-client.js";

const $ = (selector, root = document) => root.querySelector(selector);
const state = {
  user: null, profile: null,
  preferences: { feed_mode: "for_you", personalized_feed_enabled: true, interests: [] },
  relationships: new Map(), posts: [], reactions: new Map(), bookmarks: new Set(),
  commentsOpen: new Set(), loading: false
};
const statusNode = $("#social-status");
function setStatus(message, kind = "info") { statusNode.textContent = message || ""; statusNode.dataset.kind = kind; }
function el(tag, className, text) { const node = document.createElement(tag); if (className) node.className = className; if (text !== undefined) node.textContent = text; return node; }
function button(text, className, action) { const node = el("button", className, text); node.type = "button"; node.addEventListener("click", action); return node; }
function initials(name) { return (name || "N").trim().split(/\s+/).slice(0, 2).map(part => part[0] || "").join("").toUpperCase(); }
function avatar(profile, size = "normal") {
  const name = profile?.display_name || profile?.username || "Usuario NOVA";
  if (profile?.avatar_url && /^https:\/\//i.test(profile.avatar_url)) {
    const img = el("img", "social-avatar " + size); img.src = profile.avatar_url; img.alt = ""; img.loading = "lazy"; img.referrerPolicy = "no-referrer"; return img;
  }
  return el("span", "social-avatar avatar-fallback " + size, initials(name));
}
function timeLabel(value) {
  const date = new Date(value), seconds = Math.max(0, Math.floor((Date.now() - date.getTime()) / 1000));
  if (seconds < 60) return "Ahora"; if (seconds < 3600) return Math.floor(seconds / 60) + " min";
  if (seconds < 86400) return Math.floor(seconds / 3600) + " h"; if (seconds < 604800) return Math.floor(seconds / 86400) + " d";
  return new Intl.DateTimeFormat("es", { day: "numeric", month: "short" }).format(date);
}
function profileName(profile) { return profile?.display_name || profile?.username || "Usuario NOVA"; }
function normaliseProfileRelation(value) { return Array.isArray(value) ? value[0] : value; }
function safeTags(value) { return (value || "").split(",").map(tag => tag.trim().toLowerCase().replace(/[^\p{L}\p{N}_-]/gu, "").slice(0, 30)).filter(Boolean).slice(0, 8); }
function slug(value) { return (value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().replace(/[^a-z0-9_]+/g, "_").replace(/^_+|_+$/g, "").slice(0, 22) || "novauser"; }
function openAccountMenu() { const accountButton = $(".nova-account-btn"); if (accountButton) accountButton.click(); else setStatus("Abre el menú de usuario para iniciar sesión.", "warning"); }
function showSignedOut() { $("#social-auth-wall").hidden = false; $("#social-app").hidden = true; setStatus("Inicia sesión con tu cuenta NOVA para participar en la comunidad."); }
function showSignedIn() { $("#social-auth-wall").hidden = true; $("#social-app").hidden = false; }
async function ensureProfile(user) {
  const { data, error } = await supabase.from("nova_social_profiles").select("*").eq("user_id", user.id).maybeSingle();
  if (error) throw error; if (data) return data;
  const metadata = user.user_metadata || {};
  const displayName = String(metadata.full_name || metadata.name || user.email?.split("@")[0] || "Usuario NOVA").slice(0, 80);
  const username = (slug(metadata.preferred_username || displayName) + "_" + user.id.replace(/-/g, "").slice(0, 6)).slice(0, 30);
  const { data: created, error: createError } = await supabase.from("nova_social_profiles").insert({ user_id: user.id, username, display_name: displayName }).select("*").single();
  if (createError) { const retry = await supabase.from("nova_social_profiles").select("*").eq("user_id", user.id).maybeSingle(); if (retry.data) return retry.data; throw createError; }
  return created;
}
async function ensurePreferences(user) {
  const { data, error } = await supabase.from("nova_social_preferences").select("*").eq("user_id", user.id).maybeSingle();
  if (error) throw error; if (data) return data;
  const { data: created, error: createError } = await supabase.from("nova_social_preferences").insert({ user_id: user.id }).select("*").single();
  if (createError) throw createError; return created;
}
async function loadRelationships() {
  const { data, error } = await supabase.from("nova_social_follows").select("followed_id,status").eq("follower_id", state.user.id);
  if (error) throw error; state.relationships = new Map((data || []).map(item => [item.followed_id, item.status]));
}
async function loadFeed() {
  if (!state.user || state.loading) return;
  state.loading = true; setStatus("Cargando publicaciones…");
  try {
    await loadRelationships();
    const { data, error } = await supabase.from("nova_social_posts")
      .select("id,author_id,body,link_url,tags,visibility,created_at,updated_at,nova_social_profiles!nova_social_posts_author_id_fkey(user_id,username,display_name,avatar_url,is_private)")
      .eq("status", "published").order("created_at", { ascending: false }).limit(80);
    if (error) throw error;
    let posts = data || [];
    const mode = state.preferences.feed_mode || "for_you";
    if (mode === "following") {
      posts = posts.filter(post => post.author_id === state.user.id || state.relationships.get(post.author_id) === "accepted");
      posts.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    } else if (mode === "chronological" || !state.preferences.personalized_feed_enabled) {
      posts.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    } else posts = rankPosts(posts);
    state.posts = posts;
    const ids = posts.map(post => post.id); state.reactions = new Map(); state.bookmarks = new Set();
    if (ids.length) {
      const [reactionResult, bookmarkResult] = await Promise.all([
        supabase.from("nova_social_reactions").select("post_id,user_id,reaction_type").in("post_id", ids),
        supabase.from("nova_social_bookmarks").select("post_id").eq("user_id", state.user.id).in("post_id", ids)
      ]);
      if (reactionResult.error) throw reactionResult.error; if (bookmarkResult.error) throw bookmarkResult.error;
      for (const item of reactionResult.data || []) { const current = state.reactions.get(item.post_id) || { count: 0, mine: null }; current.count++; if (item.user_id === state.user.id) current.mine = item.reaction_type; state.reactions.set(item.post_id, current); }
      state.bookmarks = new Set((bookmarkResult.data || []).map(item => item.post_id));
    }
    renderFeed(); setStatus(posts.length ? posts.length + " publicaciones disponibles." : "Todavía no hay publicaciones en este feed. ¡Puedes iniciar la conversación!");
  } catch (error) { console.error("NOVA Social feed:", error); setStatus("No se pudo cargar el feed: " + (error.message || "error desconocido"), "error"); }
  finally { state.loading = false; }
}
function rankPosts(posts) {
  const interests = new Set((state.preferences.interests || []).map(value => value.toLowerCase()));
  const now = Date.now();
  const ranked = posts.map(post => {
    const ageHours = Math.max(0, (now - new Date(post.created_at).getTime()) / 3600000);
    const freshness = 1 / (1 + ageHours / 18);
    const matches = (post.tags || []).filter(tag => interests.has(String(tag).toLowerCase()));
    const followed = state.relationships.get(post.author_id) === "accepted";
    const score = freshness + (followed ? 1.8 : 0) + matches.length * 1.25 + (post.author_id === state.user.id ? 0.2 : 0);
    return { post, score };
  }).sort((a, b) => b.score - a.score);
  const result = [], remaining = ranked.slice(), recentAuthors = [];
  while (remaining.length) {
    let index = remaining.findIndex(item => recentAuthors.slice(-2).filter(id => id === item.post.author_id).length < 2);
    if (index < 0) index = 0;
    const item = remaining.splice(index, 1)[0];
    item.post.__novaReason = reasonFor(item.post, interests, state.relationships, state.user.id);
    result.push(item.post); recentAuthors.push(item.post.author_id);
  }
  return result;
}
function reasonFor(post, interests, relationships, userId) {
  const match = (post.tags || []).find(tag => interests.has(String(tag).toLowerCase()));
  if (match) return "Tema que elegiste: " + match;
  if (relationships.get(post.author_id) === "accepted") return "Sigues a esta cuenta";
  if (post.author_id === userId) return "Tu publicación";
  return "Publicación reciente";
}
function renderFeed() {
  const feed = $("#social-feed"); feed.replaceChildren();
  if (!state.posts.length) { feed.append(el("div", "social-empty", "No hay publicaciones que mostrar. Busca personas o crea la primera publicación.")); return; }
  state.posts.forEach(post => feed.append(renderPost(post)));
}
function renderPost(post) {
  const author = normaliseProfileRelation(post.nova_social_profiles) || {};
  const article = el("article", "social-post"); article.id = "post-" + post.id;
  const header = el("div", "post-header"); header.append(avatar(author));
  const authorInfo = el("div", "post-author"); authorInfo.append(el("strong", "", profileName(author)), el("span", "", "@" + (author.username || "usuario") + " · " + timeLabel(post.created_at)));
  header.append(authorInfo, el("span", "post-reason", post.__novaReason || (post.author_id === state.user.id ? "Tu publicación" : "Publicación"))); article.append(header);
  if (post.body) article.append(el("p", "post-body", post.body));
  if (post.tags?.length) { const tags = el("div", "post-tags"); post.tags.forEach(tag => tags.append(el("span", "post-tag", "#" + tag))); article.append(tags); }
  if (post.link_url) { const link = el("a", "post-link", post.link_url.replace(/^https:\/\//i, "").slice(0, 90)); link.href = post.link_url; link.target = "_blank"; link.rel = "noopener noreferrer"; article.append(link); }
  const reaction = state.reactions.get(post.id) || { count: 0, mine: null }, actions = el("div", "post-actions");
  actions.append(button((reaction.mine ? "♥" : "♡") + " Me gusta · " + reaction.count, reaction.mine ? "social-action active" : "social-action", () => toggleReaction(post.id)));
  actions.append(button("Comentar", "social-action", () => toggleComments(post.id, article)));
  actions.append(button(state.bookmarks.has(post.id) ? "Guardado" : "Guardar", state.bookmarks.has(post.id) ? "social-action active" : "social-action", () => toggleBookmark(post.id)));
  actions.append(button("Compartir", "social-action", () => sharePost(post.id)));
  if (post.author_id !== state.user.id) { actions.append(button("Denunciar", "social-action subtle", () => reportPost(post.id)), button("Bloquear", "social-action subtle", () => blockUser(post.author_id))); }
  else actions.append(button("Eliminar", "social-action subtle", () => deletePost(post.id)));
  article.append(actions); if (state.commentsOpen.has(post.id)) renderComments(post.id, article); return article;
}
async function toggleReaction(postId) {
  const existing = state.reactions.get(postId)?.mine;
  const result = existing ? await supabase.from("nova_social_reactions").delete().eq("post_id", postId).eq("user_id", state.user.id)
    : await supabase.from("nova_social_reactions").insert({ post_id: postId, user_id: state.user.id, reaction_type: "like" });
  if (result.error) return setStatus(result.error.message, "error"); await loadFeed();
}
async function toggleBookmark(postId) {
  const existing = state.bookmarks.has(postId);
  const result = existing ? await supabase.from("nova_social_bookmarks").delete().eq("post_id", postId).eq("user_id", state.user.id)
    : await supabase.from("nova_social_bookmarks").insert({ post_id: postId, user_id: state.user.id });
  if (result.error) return setStatus(result.error.message, "error"); await loadFeed();
}
async function sharePost(postId) {
  const url = new URL(location.href); url.hash = "post-" + postId;
  try { if (navigator.share) await navigator.share({ title: "Publicación NOVA", url: url.href }); else { await navigator.clipboard.writeText(url.href); setStatus("Enlace copiado."); } }
  catch (error) { if (error.name !== "AbortError") setStatus("No se pudo compartir el enlace.", "error"); }
}
async function deletePost(postId) {
  if (!confirm("¿Eliminar esta publicación?")) return;
  const { error } = await supabase.from("nova_social_posts").update({ status: "deleted", updated_at: new Date().toISOString() }).eq("id", postId).eq("author_id", state.user.id);
  if (error) return setStatus(error.message, "error"); await loadFeed();
}
async function reportPost(postId) {
  const { error } = await supabase.from("nova_social_reports").insert({ reporter_id: state.user.id, post_id: postId, reason: "other", details: "Reporte enviado desde Nova Social." });
  setStatus(error ? "No se pudo enviar el reporte: " + error.message : "Reporte recibido para revisión.", error ? "error" : "success");
}
async function blockUser(userId) {
  if (!confirm("¿Bloquear esta cuenta? Sus publicaciones y perfil dejarán de aparecerte.")) return;
  const { error } = await supabase.from("nova_social_blocks").insert({ blocker_id: state.user.id, blocked_id: userId });
  if (error) return setStatus(error.message, "error"); await loadFeed(); await loadDiscover();
}
async function toggleComments(postId, article) {
  if (state.commentsOpen.has(postId)) { state.commentsOpen.delete(postId); article.querySelector(".comment-panel")?.remove(); return; }
  state.commentsOpen.add(postId); await renderComments(postId, article);
}
async function renderComments(postId, article) {
  article.querySelector(".comment-panel")?.remove();
  const panel = el("section", "comment-panel"); panel.append(el("h3", "", "Comentarios"));
  const { data, error } = await supabase.from("nova_social_comments")
    .select("id,body,created_at,author_id,nova_social_profiles!nova_social_comments_author_id_fkey(username,display_name)")
    .eq("post_id", postId).eq("status", "published").order("created_at", { ascending: true }).limit(50);
  if (error) panel.append(el("p", "inline-error", error.message));
  else if (!data?.length) panel.append(el("p", "muted", "Todavía no hay comentarios."));
  else data.forEach(comment => { const author = normaliseProfileRelation(comment.nova_social_profiles) || {}; const line = el("p", "comment-line"); line.append(el("strong", "", profileName(author) + ": "), document.createTextNode(comment.body)); panel.append(line); });
  const form = el("form", "comment-form"), input = el("input", "social-input"), send = el("button", "social-primary", "Enviar");
  input.maxLength = 2000; input.required = true; input.placeholder = "Escribe un comentario…"; send.type = "submit"; form.append(input, send);
  form.addEventListener("submit", async event => {
    event.preventDefault(); const body = input.value.trim(); if (!body) return; send.disabled = true;
    const result = await supabase.from("nova_social_comments").insert({ post_id: postId, author_id: state.user.id, body });
    send.disabled = false; if (result.error) return setStatus(result.error.message, "error"); input.value = ""; await renderComments(postId, article);
  });
  panel.append(form); article.append(panel);
}
async function createPost(event) {
  event.preventDefault();
  const body = $("#social-compose-body").value.trim(), rawLink = $("#social-compose-link").value.trim();
  const link = rawLink ? (() => { try { const url = new URL(rawLink); return url.protocol === "https:" ? url.href : null; } catch { return null; } })() : null;
  if (!body && !link) return setStatus("Escribe algo o añade un enlace HTTPS.", "warning");
  if (rawLink && !link) return setStatus("Los enlaces deben comenzar con https://", "warning");
  const { error } = await supabase.from("nova_social_posts").insert({
    author_id: state.user.id, body, link_url: link, tags: safeTags($("#social-compose-tags").value),
    visibility: $("#social-compose-visibility").value, status: "published"
  });
  if (error) return setStatus("No se pudo publicar: " + error.message, "error");
  $("#social-compose-body").value = ""; $("#social-compose-link").value = ""; $("#social-compose-tags").value = ""; $("#social-compose-visibility").value = "public";
  setStatus("Publicación creada.", "success"); await loadFeed();
}
async function loadDiscover() {
  if (!state.user) return;
  const term = $("#people-search").value.trim().replace(/[%_]/g, "");
  let query = supabase.from("nova_social_profiles").select("user_id,username,display_name,avatar_url,is_private,created_at")
    .neq("user_id", state.user.id).eq("discoverable", true).order("created_at", { ascending: false }).limit(12);
  if (term) query = query.ilike("username", term + "%");
  const { data, error } = await query; if (error) return setStatus("No se pudieron buscar usuarios: " + error.message, "error");
  const list = $("#social-people"); list.replaceChildren();
  const people = (data || []).filter(person => !state.relationships.has(person.user_id) || state.relationships.get(person.user_id) === "rejected");
  if (!people.length) list.append(el("p", "muted", term ? "No se encontraron cuentas con ese nombre." : "No hay más cuentas sugeridas por ahora."));
  people.forEach(person => {
    const row = el("div", "person-row"), info = el("div", "person-info"); row.append(avatar(person, "small"));
    info.append(el("strong", "", profileName(person)), el("span", "", "@" + person.username + (person.is_private ? " · Privada" : "")));
    row.append(info, button(person.is_private ? "Solicitar" : "Seguir", "social-secondary", () => followPerson(person))); list.append(row);
  });
}
async function followPerson(person) {
  const { error } = await supabase.from("nova_social_follows").insert({ follower_id: state.user.id, followed_id: person.user_id, status: person.is_private ? "pending" : "accepted" });
  if (error) return setStatus(error.message, "error");
  setStatus(person.is_private ? "Solicitud enviada." : "Ahora sigues a @" + person.username + ".", "success");
  await loadRelationships(); await loadDiscover(); await loadFeed();
}
async function loadFollowRequests() {
  const { data, error } = await supabase.from("nova_social_follows")
    .select("follower_id,created_at,nova_social_profiles!nova_social_follows_follower_id_fkey(user_id,username,display_name,avatar_url)")
    .eq("followed_id", state.user.id).eq("status", "pending").order("created_at", { ascending: false }).limit(20);
  const list = $("#social-follow-requests"); list.replaceChildren();
  if (error) { list.append(el("p", "inline-error", error.message)); return; }
  if (!data?.length) { list.append(el("p", "muted", "No tienes solicitudes pendientes.")); return; }
  data.forEach(request => {
    const person = normaliseProfileRelation(request.nova_social_profiles) || {}, row = el("div", "person-row"), info = el("div", "person-info");
    row.append(avatar(person, "small")); info.append(el("strong", "", profileName(person)), el("span", "", "@" + (person.username || "usuario"))); row.append(info);
    row.append(button("Aceptar", "social-primary compact", () => decideFollow(request.follower_id, "accepted")));
    row.append(button("Rechazar", "social-secondary compact", () => decideFollow(request.follower_id, "rejected"))); list.append(row);
  });
}
async function decideFollow(followerId, decision) {
  const { error } = await supabase.from("nova_social_follows").update({ status: decision })
    .eq("follower_id", followerId).eq("followed_id", state.user.id).eq("status", "pending");
  if (error) return setStatus(error.message, "error"); await loadFollowRequests(); await loadFeed();
}
async function saveProfile(event) {
  event.preventDefault(); const username = $("#social-profile-username").value.trim().toLowerCase();
  if (!/^[a-z0-9_]{3,30}$/.test(username)) return setStatus("El usuario debe tener 3–30 caracteres: letras, números o guion bajo.", "warning");
  const avatarUrl = $("#social-profile-avatar").value.trim();
  if (avatarUrl && !/^https:\/\//i.test(avatarUrl)) return setStatus("El avatar debe usar HTTPS.", "warning");
  const { data, error } = await supabase.from("nova_social_profiles").update({
    username, display_name: $("#social-profile-name").value.trim().slice(0, 80), bio: $("#social-profile-bio").value.trim().slice(0, 280),
    avatar_url: avatarUrl || null, is_private: $("#social-profile-private").checked, updated_at: new Date().toISOString()
  }).eq("user_id", state.user.id).select("*").single();
  if (error) return setStatus("No se pudo guardar el perfil: " + error.message, "error"); state.profile = data; setStatus("Perfil actualizado.", "success");
}
async function savePreferences(event) {
  event.preventDefault(); const interests = safeTags($("#social-interests").value).slice(0, 20);
  const { data, error } = await supabase.from("nova_social_preferences").upsert({
    user_id: state.user.id, feed_mode: $("#social-feed-mode").value, personalized_feed_enabled: $("#social-personalized").checked,
    interests, updated_at: new Date().toISOString()
  }, { onConflict: "user_id" }).select("*").single();
  if (error) return setStatus("No se pudieron guardar las preferencias: " + error.message, "error");
  state.preferences = data; setStatus("Preferencias guardadas. El feed se actualizará con tus elecciones.", "success"); await loadFeed();
}
function paintForms() {
  $("#social-profile-username").value = state.profile.username || ""; $("#social-profile-name").value = state.profile.display_name || "";
  $("#social-profile-bio").value = state.profile.bio || ""; $("#social-profile-avatar").value = state.profile.avatar_url || "";
  $("#social-profile-private").checked = !!state.profile.is_private; $("#social-interests").value = (state.preferences.interests || []).join(", ");
  $("#social-feed-mode").value = state.preferences.feed_mode || "for_you"; $("#social-personalized").checked = !!state.preferences.personalized_feed_enabled;
  document.querySelectorAll("[data-feed-mode]").forEach(node => node.setAttribute("aria-pressed", String(node.dataset.feedMode === state.preferences.feed_mode)));
}
async function startSession(user) {
  if (!user || state.user?.id === user.id) return; state.user = user;
  try {
    showSignedIn(); state.profile = await ensureProfile(user); state.preferences = await ensurePreferences(user); paintForms();
    await loadRelationships(); await Promise.all([loadFeed(), loadDiscover(), loadFollowRequests()]);
  } catch (error) { console.error("NOVA Social init:", error); setStatus("No se pudo iniciar NOVA Social: " + (error.message || "error desconocido"), "error"); }
}
$("#social-sign-in").addEventListener("click", openAccountMenu);
$("#social-compose-form").addEventListener("submit", createPost);
$("#social-profile-form").addEventListener("submit", saveProfile);
$("#social-preferences-form").addEventListener("submit", savePreferences);
$("#social-search-form").addEventListener("submit", event => { event.preventDefault(); loadDiscover(); });
$("#social-discover-refresh").addEventListener("click", loadDiscover);
$("#social-feed-refresh").addEventListener("click", loadFeed);
document.querySelectorAll("[data-feed-mode]").forEach(node => node.addEventListener("click", async () => {
  const mode = node.dataset.feedMode; state.preferences = { ...state.preferences, feed_mode: mode }; $("#social-feed-mode").value = mode;
  document.querySelectorAll("[data-feed-mode]").forEach(item => item.setAttribute("aria-pressed", String(item === node)));
  const { error } = await supabase.from("nova_social_preferences").upsert({
    user_id: state.user.id, feed_mode: mode, personalized_feed_enabled: state.preferences.personalized_feed_enabled,
    interests: state.preferences.interests || [], updated_at: new Date().toISOString()
  }, { onConflict: "user_id" });
  if (error) setStatus(error.message, "error"); else await loadFeed();
}));
supabase.auth.onAuthStateChange((event, session) => {
  if (event === "SIGNED_OUT") { state.user = null; state.profile = null; showSignedOut(); }
  else if (session?.user && ["SIGNED_IN", "TOKEN_REFRESHED", "USER_UPDATED"].includes(event)) startSession(session.user);
});
supabase.auth.getSession().then(({ data, error }) => {
  if (error) setStatus(error.message, "error"); if (data?.session?.user) startSession(data.session.user); else showSignedOut();
}).catch(error => setStatus(error.message, "error"));
