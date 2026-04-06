import { useState } from "react";
import { Home, Package, Calendar, ShoppingCart, Users, Clock, Plus, X, Check, Sparkles, Loader, Search, Heart, Star } from "lucide-react";

const C = {
  amber: "#E8901A", amberBg: "#FFF3E6", dark: "#1C1208",
  cream: "#F8F3EB", green: "#3D7A1E", greenBg: "#ECF5E3",
  white: "#FFFFFF", muted: "#8B7355", border: "#EDE4D3",
  special: "#C4621A", specialBg: "#FEF0E0",
};

const RECIPES_DEFAULT = [
  { id:1, name:"Miso-Ramen mit Shiitake", time:35, match:95, uses:["Miso Paste","Fischsauce"], cat:"Japanisch", emoji:"🍜", batch:false, desc:"Umami-reiche Brühe mit frischen Shiitake-Pilzen" },
  { id:2, name:"Miso-Aubergine & Sesamreis", time:40, match:92, uses:["Miso Paste"], cat:"Japanisch", emoji:"🍆", batch:true, desc:"Glasierte Aubergine auf fluffigem Sesamreis" },
  { id:3, name:"Linsen-Dhal mit Tamarinde", time:30, match:88, uses:["Linsen","Tamarinde"], cat:"Indisch", emoji:"🍛", batch:true, desc:"Cremiges Dhal mit würziger Tamarinden-Note" },
  { id:4, name:"Sumach-Hähnchen auf Reis", time:45, match:84, uses:["Sumach"], cat:"Arabisch", emoji:"🍗", batch:false, desc:"Orientalisches Hähnchen mit Sumach-Würze" },
];

const PANTRY_DEFAULT = [
  { id:1, name:"Miso Paste", special:true, amount:"200g" },
  { id:2, name:"Fischsauce", special:true, amount:"300ml" },
  { id:3, name:"Sumach", special:true, amount:"50g" },
  { id:4, name:"Tamarinde", special:true, amount:"100g" },
  { id:5, name:"Knoblauch", special:false, amount:"1 Knolle" },
  { id:6, name:"Olivenöl", special:false, amount:"500ml" },
  { id:7, name:"Pasta", special:false, amount:"500g" },
  { id:8, name:"Zwiebeln", special:false, amount:"5 Stück" },
  { id:9, name:"Linsen", special:false, amount:"400g" },
  { id:10, name:"Tomaten", special:false, amount:"4 Stück" },
];

const SHOPPING_DEFAULT = [
  { id:1, name:"Ramen Nudeln", amount:"200g", done:false, cat:"Nudeln" },
  { id:2, name:"Shiitake Pilze", amount:"150g", done:false, cat:"Gemüse" },
  { id:3, name:"Frühlingszwiebeln", amount:"1 Bund", done:true, cat:"Gemüse" },
  { id:4, name:"Tofu", amount:"400g", done:false, cat:"Protein" },
  { id:5, name:"Hähnchenbrust", amount:"500g", done:false, cat:"Protein" },
  { id:6, name:"Kokosmilch", amount:"400ml", done:false, cat:"Konserven" },
];

const WEEK_DEFAULT = [
  { day:"Mo", recipe:"Linsen-Dhal", emoji:"🍛" },
  { day:"Di", recipe:null, emoji:null },
  { day:"Mi", recipe:"Miso-Ramen", emoji:"🍜" },
  { day:"Do", recipe:null, emoji:null },
  { day:"Fr", recipe:"Bolognese", emoji:"🍝" },
  { day:"Sa", recipe:"Sumach-Hähnchen", emoji:"🍗" },
  { day:"So", recipe:null, emoji:null },
];

const SOCIAL = [
  { id:1, initials:"LK", name:"Lena K.", color:"#E8901A", action:"kocht gerade", dish:"Marokkanisches Lamm-Tajine", emoji:"🫕", likes:5, time:"10 Min" },
  { id:2, initials:"JM", name:"Jonas M.", color:"#3D7A1E", action:"hat eingefroren", dish:"Bolognese (8 Portionen)", emoji:"🍝", likes:3, time:"2 Std", frozen:true },
  { id:3, initials:"MT", name:"Mia & Tom", color:"#C4621A", action:"laden ein", dish:"Gemeinsam Kochen – Samstag Abend", emoji:"🎉", likes:0, time:"1 Tag", invite:true },
  { id:4, initials:"SP", name:"Sarah P.", color:"#7B5EA7", action:"hat gekocht", dish:"Pad Thai mit Erdnüssen", emoji:"🍜", likes:8, time:"3 Std" },
];

// Deterministic: changes once per day
function getDailyRecipe(recipes) {
  const now = new Date();
  const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 86400000);
  return recipes[dayOfYear % recipes.length];
}

// ── Rezept des Tages ─────────────────────────────────────────────────────────
function RecipeOfTheDay({ recipe, onShop }) {
  return (
    <div style={{ borderRadius: 20, overflow: "hidden", marginBottom: 20, boxShadow: "0 6px 28px rgba(28,18,8,0.15)" }}>
      <div style={{ background: "#2A1A07", padding: "10px 18px", display: "flex", alignItems: "center", gap: 7 }}>
        <Star size={12} color="#E8901A" fill="#E8901A" />
        <span style={{ fontSize: 10, fontWeight: 800, color: "#E8901A", letterSpacing: 1.2 }}>REZEPT DES TAGES</span>
      </div>
      <div style={{ background: "linear-gradient(160deg, #2E1F0A 0%, #3D2910 100%)", padding: "22px 20px 20px" }}>
        <div style={{ fontSize: 64, textAlign: "center", lineHeight: 1, marginBottom: 14, filter: "drop-shadow(0 4px 12px rgba(0,0,0,0.4))" }}>
          {recipe.emoji}
        </div>
        <div style={{ textAlign: "center" }}>
          <div style={{ display: "flex", justifyContent: "center", gap: 6, marginBottom: 10, flexWrap: "wrap" }}>
            <span style={{ fontSize: 10, fontWeight: 700, color: "#E8901A", background: "rgba(232,144,26,0.18)", padding: "3px 10px", borderRadius: 20 }}>
              {recipe.cat?.toUpperCase()}
            </span>
            {recipe.batch && (
              <span style={{ fontSize: 10, fontWeight: 700, color: "#6FCF4A", background: "rgba(111,207,74,0.15)", padding: "3px 10px", borderRadius: 20 }}>
                ❄ BATCH COOK
              </span>
            )}
          </div>
          <h2 style={{ margin: "0 0 8px", fontSize: 21, fontWeight: 800, color: "#FFFFFF", lineHeight: 1.25 }}>{recipe.name}</h2>
          <p style={{ margin: "0 0 18px", fontSize: 13, color: "rgba(255,255,255,0.55)", lineHeight: 1.5 }}>{recipe.desc}</p>

          <div style={{ display: "flex", justifyContent: "center", gap: 28, marginBottom: 20 }}>
            <div style={{ textAlign: "center" }}>
              <div style={{ fontSize: 20, fontWeight: 800, color: "#FFFFFF" }}>{recipe.time}</div>
              <div style={{ fontSize: 10, color: "rgba(255,255,255,0.4)", marginTop: 2, letterSpacing: 0.5 }}>MINUTEN</div>
            </div>
            <div style={{ width: 1, background: "rgba(255,255,255,0.12)", alignSelf: "stretch" }} />
            <div style={{ textAlign: "center" }}>
              <div style={{ fontSize: 20, fontWeight: 800, color: recipe.match > 90 ? "#6FCF4A" : "#E8901A" }}>{recipe.match}%</div>
              <div style={{ fontSize: 10, color: "rgba(255,255,255,0.4)", marginTop: 2, letterSpacing: 0.5 }}>VORRAT</div>
            </div>
            {recipe.uses?.length > 0 && (
              <>
                <div style={{ width: 1, background: "rgba(255,255,255,0.12)", alignSelf: "stretch" }} />
                <div style={{ textAlign: "center" }}>
                  <div style={{ fontSize: 20, fontWeight: 800, color: "#FFB347" }}>{recipe.uses.length}</div>
                  <div style={{ fontSize: 10, color: "rgba(255,255,255,0.4)", marginTop: 2, letterSpacing: 0.5 }}>SPEZIAL</div>
                </div>
              </>
            )}
          </div>

          {recipe.uses?.length > 0 && (
            <div style={{ display: "flex", justifyContent: "center", flexWrap: "wrap", gap: 6, marginBottom: 18 }}>
              {recipe.uses.map(u => (
                <span key={u} style={{ fontSize: 11, fontWeight: 700, color: "#FFB347", background: "rgba(255,179,71,0.15)", padding: "4px 12px", borderRadius: 20 }}>
                  ✦ {u}
                </span>
              ))}
            </div>
          )}

          <div style={{ display: "flex", gap: 10 }}>
            <button
              onClick={() => onShop(recipe)}
              style={{ flex: 1, background: "#E8901A", color: "#fff", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 700, cursor: "pointer" }}>
              + Einkaufsliste
            </button>
            <button
              style={{ flex: 1, background: "rgba(255,255,255,0.1)", color: "#FFFFFF", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 600, cursor: "pointer" }}>
              Rezept ansehen →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Compact AI suggestion card ───────────────────────────────────────────────
function RecipeCard({ r, rank, onShop }) {
  return (
    <div style={{ background: C.white, borderRadius: 14, border: `1px solid ${C.border}`, marginBottom: 10, overflow: "hidden" }}>
      <div style={{ padding: "13px 15px", display: "flex", gap: 12, alignItems: "flex-start" }}>
        <div style={{ fontSize: 38, lineHeight: 1, flexShrink: 0 }}>{r.emoji}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 5, marginBottom: 5 }}>
            <span style={{ fontSize: 9, fontWeight: 700, color: C.muted, background: "#F0EBE2", padding: "2px 7px", borderRadius: 20 }}>
              {r.cat?.toUpperCase()}
            </span>
            {r.batch && (
              <span style={{ fontSize: 9, fontWeight: 700, color: C.green, background: C.greenBg, padding: "2px 7px", borderRadius: 20 }}>
                ❄ BATCH
              </span>
            )}
            {rank === 0 && (
              <span style={{ fontSize: 9, fontWeight: 700, color: C.amber, background: C.amberBg, padding: "2px 7px", borderRadius: 20 }}>
                ★ TOP PICK
              </span>
            )}
          </div>
          <div style={{ fontSize: 15, fontWeight: 700, color: C.dark, lineHeight: 1.3 }}>{r.name}</div>
          {r.desc && <div style={{ fontSize: 11, color: C.muted, marginTop: 3 }}>{r.desc}</div>}
        </div>
      </div>

      <div style={{ padding: "0 15px 8px", display: "flex", alignItems: "center", gap: 12 }}>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 10, color: C.muted, marginBottom: 4 }}>
            <span>Vorratstreffer</span>
            <strong style={{ color: r.match > 90 ? C.green : C.amber }}>{r.match}%</strong>
          </div>
          <div style={{ background: "#EDE4D3", borderRadius: 3, height: 4 }}>
            <div style={{ background: r.match > 90 ? C.green : C.amber, width: r.match + "%", height: 4, borderRadius: 3 }} />
          </div>
        </div>
        <div style={{ fontSize: 11, color: C.muted, display: "flex", alignItems: "center", gap: 3, flexShrink: 0 }}>
          <Clock size={11} /> {r.time} Min
        </div>
      </div>

      {r.uses?.length > 0 && (
        <div style={{ padding: "0 15px 8px", display: "flex", flexWrap: "wrap", gap: 5 }}>
          {r.uses.map(u => (
            <span key={u} style={{ fontSize: 9, fontWeight: 700, color: C.special, background: C.specialBg, padding: "2px 8px", borderRadius: 20 }}>
              ✦ {u}
            </span>
          ))}
        </div>
      )}

      <div style={{ padding: "8px 15px 13px", display: "flex", gap: 8 }}>
        <button onClick={onShop} style={{ flex: 1, background: C.amber, color: "#fff", border: "none", borderRadius: 9, padding: "9px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
          + Einkaufsliste
        </button>
        <button style={{ background: "#F0EBE2", color: C.muted, border: "none", borderRadius: 9, padding: "9px 13px", fontSize: 12, cursor: "pointer" }}>
          Rezept →
        </button>
      </div>
    </div>
  );
}

// ── Home Screen ──────────────────────────────────────────────────────────────
function HomeScreen({ recipes, pantry, loading, onLoadAI, onAddToShopping }) {
  const h = new Date().getHours();
  const greeting = h < 12 ? "Guten Morgen" : h < 17 ? "Guten Mittag" : "Guten Abend";
  const specials = pantry.filter(p => p.special);
  const dailyRecipe = getDailyRecipe(recipes);

  return (
    <div style={{ padding: 16 }}>
      {/* Greeting */}
      <div style={{ marginBottom: 20 }}>
        <p style={{ margin: 0, fontSize: 13, color: C.muted }}>{greeting} 👋</p>
        <h2 style={{ margin: "3px 0 0", fontSize: 23, fontWeight: 800, color: C.dark }}>Was kochen wir heute?</h2>
      </div>

      {/* ── Rezept des Tages ── */}
      <RecipeOfTheDay recipe={dailyRecipe} onShop={onAddToShopping} />

      {/* Sonderzutaten-Hinweis */}
      {specials.length > 0 && (
        <div style={{ background: C.specialBg, border: `1px solid ${C.special}33`, borderRadius: 12, padding: "10px 14px", marginBottom: 18, display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 16 }}>✦</span>
          <div>
            <div style={{ fontSize: 10, fontWeight: 700, color: C.special, letterSpacing: 0.5 }}>SONDERZUTATEN — BALD VERBRAUCHEN</div>
            <div style={{ fontSize: 11, color: C.muted, marginTop: 1 }}>{specials.map(s => s.name).join(" · ")}</div>
          </div>
        </div>
      )}

      {/* ── KI Vorschläge Section ── */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
        <div>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.muted, letterSpacing: 0.5, marginBottom: 2 }}>PASSEND ZU DEINEM VORRAT</div>
          <div style={{ fontSize: 16, fontWeight: 700, color: C.dark }}>KI-Vorschläge</div>
        </div>
        <button
          onClick={onLoadAI}
          disabled={loading}
          style={{
            background: loading ? "#C4A882" : C.dark,
            color: "#fff", border: "none", borderRadius: 12,
            padding: "9px 14px", fontSize: 12, fontWeight: 700,
            cursor: loading ? "wait" : "pointer",
            display: "flex", alignItems: "center", gap: 7,
            flexShrink: 0,
          }}
        >
          {loading ? <Loader size={13} /> : <Sparkles size={13} />}
          {loading ? "Lädt…" : "Neu laden"}
        </button>
      </div>

      {recipes.map((r, i) => (
        <RecipeCard key={r.id} r={r} rank={i} onShop={() => onAddToShopping(r)} />
      ))}
    </div>
  );
}

// ── Pantry Screen ────────────────────────────────────────────────────────────
function PantryRow({ item, onToggle, onRemove }) {
  return (
    <div style={{ background: item.special ? C.specialBg : C.white, border: `1px solid ${item.special ? C.special + "44" : C.border}`, borderRadius: 12, padding: "10px 14px", marginBottom: 8, display: "flex", alignItems: "center", gap: 12 }}>
      <div style={{ flex: 1 }}>
        <p style={{ margin: 0, fontWeight: 600, color: C.dark, fontSize: 14 }}>{item.name}</p>
        <p style={{ margin: 0, fontSize: 11, color: C.muted }}>{item.amount}</p>
      </div>
      <button onClick={() => onToggle(item.id)} title={item.special ? "Als normal markieren" : "Als Sondervorrat ✦"} style={{ fontSize: 18, background: "none", border: "none", cursor: "pointer", color: item.special ? C.special : "#CCC", padding: "0 4px", lineHeight: 1 }}>✦</button>
      <button onClick={() => onRemove(item.id)} style={{ background: "none", border: "none", cursor: "pointer", color: "#CCC", padding: 4, display: "flex" }}>
        <X size={14} />
      </button>
    </div>
  );
}

function PantryScreen({ pantry, setPantry }) {
  const [search, setSearch] = useState("");
  const [newItem, setNewItem] = useState("");
  const [newAmt, setNewAmt] = useState("");
  const filtered = pantry.filter(p => !search || p.name.toLowerCase().includes(search.toLowerCase()));
  const specials = filtered.filter(p => p.special);
  const regular = filtered.filter(p => !p.special);
  const toggle = (id) => setPantry(p => p.map(i => i.id === id ? { ...i, special: !i.special } : i));
  const remove = (id) => setPantry(p => p.filter(i => i.id !== id));
  const add = () => {
    if (!newItem.trim()) return;
    setPantry(p => [...p, { id: Date.now(), name: newItem.trim(), special: false, amount: newAmt.trim() || "vorhanden" }]);
    setNewItem(""); setNewAmt("");
  };
  return (
    <div style={{ padding: 16 }}>
      <div style={{ display: "flex", alignItems: "center", background: C.white, border: `1px solid ${C.border}`, borderRadius: 12, padding: "8px 14px", gap: 8, marginBottom: 12 }}>
        <Search size={14} color={C.muted} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Suchen…" style={{ border: "none", outline: "none", flex: 1, fontSize: 14, background: "transparent", color: C.dark }} />
      </div>
      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <input value={newItem} onChange={e => setNewItem(e.target.value)} onKeyDown={e => e.key === "Enter" && add()} placeholder="Neue Zutat…" style={{ flex: 2, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 12px", fontSize: 14, outline: "none", background: C.white, color: C.dark }} />
        <input value={newAmt} onChange={e => setNewAmt(e.target.value)} onKeyDown={e => e.key === "Enter" && add()} placeholder="Menge" style={{ flex: 1, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 8px", fontSize: 14, outline: "none", background: C.white, color: C.dark }} />
        <button onClick={add} style={{ background: C.amber, color: "#fff", border: "none", borderRadius: 10, padding: "10px 16px", fontSize: 18, fontWeight: 700, cursor: "pointer" }}>+</button>
      </div>
      {specials.length > 0 && (<>
        <p style={{ margin: "0 0 8px", fontSize: 11, fontWeight: 700, color: C.special, letterSpacing: 0.5 }}>✦ SONDERZUTATEN · werden gezielt verbraucht</p>
        {specials.map(item => <PantryRow key={item.id} item={item} onToggle={toggle} onRemove={remove} />)}
        <div style={{ height: 8 }} />
      </>)}
      <p style={{ margin: "0 0 8px", fontSize: 11, fontWeight: 700, color: C.muted, letterSpacing: 0.5 }}>VORRAT</p>
      {regular.map(item => <PantryRow key={item.id} item={item} onToggle={toggle} onRemove={remove} />)}
      {regular.length === 0 && !search && <p style={{ margin: 0, fontSize: 13, color: C.muted, textAlign: "center", padding: "20px 0" }}>Noch keine normalen Zutaten. Füge welche hinzu ↑</p>}
    </div>
  );
}

// ── Shopping Screen ──────────────────────────────────────────────────────────
function ShoppingScreen({ shopping, setShopping }) {
  const [newItem, setNewItem] = useState("");
  const doneCount = shopping.filter(s => s.done).length;
  const cats = [...new Set(shopping.map(s => s.cat))];
  const toggle = (id) => setShopping(s => s.map(i => i.id === id ? { ...i, done: !i.done } : i));
  const remove = (id) => setShopping(s => s.filter(i => i.id !== id));
  const add = () => {
    if (!newItem.trim()) return;
    setShopping(s => [...s, { id: Date.now(), name: newItem.trim(), amount: "", done: false, cat: "Sonstiges" }]);
    setNewItem("");
  };
  return (
    <div style={{ padding: 16 }}>
      <div style={{ background: C.white, borderRadius: 14, padding: "14px", marginBottom: 14, border: `1px solid ${C.border}` }}>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, marginBottom: 8 }}>
          <span style={{ fontWeight: 600, color: C.dark }}>Fortschritt</span>
          <span style={{ color: C.muted }}>{doneCount} / {shopping.length} erledigt</span>
        </div>
        <div style={{ background: "#EDE4D3", borderRadius: 4, height: 6 }}>
          <div style={{ background: C.green, width: Math.round(doneCount / Math.max(shopping.length, 1) * 100) + "%", height: 6, borderRadius: 4, transition: "width 0.3s" }} />
        </div>
      </div>
      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <input value={newItem} onChange={e => setNewItem(e.target.value)} onKeyDown={e => e.key === "Enter" && add()} placeholder="Zutat hinzufügen…" style={{ flex: 1, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 12px", fontSize: 14, outline: "none", background: C.white, color: C.dark }} />
        <button onClick={add} style={{ background: C.amber, color: "#fff", border: "none", borderRadius: 10, padding: "10px 18px", fontSize: 18, fontWeight: 700, cursor: "pointer" }}>+</button>
      </div>
      {cats.map(cat => (
        <div key={cat} style={{ marginBottom: 14 }}>
          <p style={{ margin: "0 0 6px", fontSize: 11, fontWeight: 700, color: C.muted, letterSpacing: 0.5 }}>{cat.toUpperCase()}</p>
          {shopping.filter(s => s.cat === cat).map(item => (
            <div key={item.id} style={{ background: C.white, border: `1px solid ${C.border}`, borderRadius: 12, padding: "10px 14px", marginBottom: 6, display: "flex", alignItems: "center", gap: 12, opacity: item.done ? 0.5 : 1 }}>
              <button onClick={() => toggle(item.id)} style={{ width: 24, height: 24, borderRadius: 8, border: `2px solid ${item.done ? C.green : "#DDD"}`, background: item.done ? C.green : "transparent", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
                {item.done && <Check size={12} color="#fff" />}
              </button>
              <div style={{ flex: 1, minWidth: 0 }}>
                <p style={{ margin: 0, fontSize: 14, fontWeight: 500, color: C.dark, textDecoration: item.done ? "line-through" : "none" }}>{item.name}</p>
                {item.amount && <p style={{ margin: 0, fontSize: 11, color: C.muted }}>{item.amount}</p>}
              </div>
              <button onClick={() => remove(item.id)} style={{ background: "none", border: "none", cursor: "pointer", color: "#CCC", flexShrink: 0, display: "flex" }}>
                <X size={14} />
              </button>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

// ── Planner Screen ───────────────────────────────────────────────────────────
function PlannerScreen({ week, setWeek, recipes }) {
  return (
    <div style={{ padding: 16 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
        <h3 style={{ margin: 0, fontSize: 15, fontWeight: 700, color: C.dark }}>Diese Woche</h3>
        <button onClick={() => {
          setWeek(w => w.map((d, i) => ({ ...d, recipe: recipes[i % recipes.length]?.name || null, emoji: recipes[i % recipes.length]?.emoji || null })));
        }} style={{ background: C.amber, color: "#fff", border: "none", borderRadius: 10, padding: "8px 14px", fontSize: 12, fontWeight: 600, cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
          <Sparkles size={12} /> KI planen
        </button>
      </div>
      {week.map((day, i) => (
        <div key={day.day} style={{ background: day.recipe ? C.white : C.cream, border: `1px solid ${day.recipe ? C.border : "transparent"}`, borderRadius: 14, padding: "12px 16px", marginBottom: 8, display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{ textAlign: "center", minWidth: 32 }}>
            <p style={{ margin: 0, fontSize: 10, fontWeight: 700, color: C.muted }}>{day.day}</p>
            <p style={{ margin: 0, fontSize: 18, fontWeight: 700, color: day.recipe ? C.amber : "#CCC" }}>{i + 1}</p>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            {day.recipe ? (
              <p style={{ margin: 0, fontSize: 14, fontWeight: 600, color: C.dark }}>{day.emoji} {day.recipe}</p>
            ) : (
              <button onClick={() => { const r = recipes[Math.floor(Math.random() * recipes.length)]; setWeek(w => w.map((d, idx) => idx === i ? { ...d, recipe: r.name, emoji: r.emoji } : d)); }} style={{ background: "none", border: "none", cursor: "pointer", color: C.muted, fontSize: 13, display: "flex", alignItems: "center", gap: 6, padding: 0 }}>
                <Plus size={13} /> Rezept wählen
              </button>
            )}
          </div>
          {day.recipe && (
            <button onClick={() => setWeek(w => w.map((d, idx) => idx === i ? { ...d, recipe: null, emoji: null } : d))} style={{ background: "none", border: "none", cursor: "pointer", color: "#CCC", display: "flex" }}>
              <X size={14} />
            </button>
          )}
        </div>
      ))}
      <div style={{ background: C.greenBg, border: `1px solid ${C.green}33`, borderRadius: 14, padding: "12px 14px", marginTop: 4 }}>
        <p style={{ margin: "0 0 4px", fontSize: 11, fontWeight: 700, color: C.green }}>❄ BATCH COOK TIPP</p>
        <p style={{ margin: 0, fontSize: 12, color: C.muted }}>Linsen-Dhal und Bolognese eignen sich ideal zum Einfrieren. Koche doppelte Menge und spare 3x Zeit pro Woche!</p>
      </div>
    </div>
  );
}

// ── Social Screen ────────────────────────────────────────────────────────────
function SocialScreen({ liked, setLiked }) {
  return (
    <div style={{ padding: 16 }}>
      <h3 style={{ margin: "0 0 14px", fontSize: 15, fontWeight: 700, color: C.dark }}>Was Freunde kochen</h3>
      {SOCIAL.map(post => (
        <div key={post.id} style={{ background: C.white, borderRadius: 16, border: `1px solid ${C.border}`, padding: "14px 16px", marginBottom: 12 }}>
          <div style={{ display: "flex", gap: 12 }}>
            <div style={{ width: 42, height: 42, borderRadius: 21, background: post.color + "20", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, fontWeight: 700, color: post.color, flexShrink: 0 }}>
              {post.initials}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ margin: 0, fontSize: 14, fontWeight: 700, color: C.dark }}>{post.name}</p>
              <p style={{ margin: "2px 0 0", fontSize: 11, color: C.muted }}>{post.action} · vor {post.time}</p>
              <p style={{ margin: "8px 0 0", fontSize: 15 }}>{post.emoji} <strong style={{ color: C.dark }}>{post.dish}</strong></p>
            </div>
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 10 }}>
            <button onClick={() => setLiked(l => ({ ...l, [post.id]: !l[post.id] }))} style={{ background: liked[post.id] ? "#FFE8E8" : C.cream, color: liked[post.id] ? "#E33" : C.muted, border: "none", borderRadius: 20, padding: "6px 14px", fontSize: 12, cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
              <Heart size={12} fill={liked[post.id] ? "#E33" : "none"} color={liked[post.id] ? "#E33" : C.muted} />
              {(post.likes || 0) + (liked[post.id] ? 1 : 0)}
            </button>
            {post.invite
              ? <button style={{ background: C.amber, color: "#fff", border: "none", borderRadius: 20, padding: "6px 14px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>Zusagen →</button>
              : <button style={{ background: C.cream, color: C.muted, border: "none", borderRadius: 20, padding: "6px 14px", fontSize: 12, cursor: "pointer" }}>Rezept übernehmen</button>
            }
            {post.frozen && <span style={{ fontSize: 10, fontWeight: 700, color: "#4B9CD3", background: "#E8F4FF", padding: "4px 10px", borderRadius: 20, display: "flex", alignItems: "center" }}>❄ Eingefroren</span>}
          </div>
        </div>
      ))}
    </div>
  );
}

// ── Tab config ───────────────────────────────────────────────────────────────
const TABS = [
  { id: "home", icon: Home, label: "Heute" },
  { id: "pantry", icon: Package, label: "Vorrat" },
  { id: "shopping", icon: ShoppingCart, label: "Einkauf" },
  { id: "planner", icon: Calendar, label: "Planer" },
  { id: "social", icon: Users, label: "Social" },
];
const TITLES = { home: "Next Cooking", pantry: "Mein Vorrat", shopping: "Einkaufsliste", planner: "Wochenplan", social: "Freunde" };

// ── App ──────────────────────────────────────────────────────────────────────
export default function App() {
  const [tab, setTab] = useState("home");
  const [pantry, setPantry] = useState(PANTRY_DEFAULT);
  const [shopping, setShopping] = useState(SHOPPING_DEFAULT);
  const [week, setWeek] = useState(WEEK_DEFAULT);
  const [recipes, setRecipes] = useState(RECIPES_DEFAULT);
  const [loading, setLoading] = useState(false);
  const [liked, setLiked] = useState({});

  const loadAI = async () => {
    setLoading(true);
    const special = pantry.filter(p => p.special).map(p => p.name).join(", ");
    const all = pantry.map(p => p.name).join(", ");
    try {
      const res = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 900,
          messages: [{ role: "user", content: `Du bist Kochassistent für "Next Cooking". Mein Vorrat: ${all}. Sonderzutaten die verbraucht werden müssen: ${special}. Erstelle 4 passende Rezeptvorschläge. Antworte NUR mit einem JSON-Array, kein Markdown, kein Text: [{"id":1,"name":"Rezeptname","time":30,"match":95,"uses":["Zutat1","Zutat2"],"cat":"Küche","emoji":"🍜","batch":false,"desc":"Kurze appetitliche Beschreibung"}]. Sonderzutaten in mindestens 2 Vorschlägen einbauen. match=Vorratstreffer in %, batch=true wenn gut zum Einfrieren.` }]
        })
      });
      const d = await res.json();
      const text = (d.content || []).map(b => b.text || "").join("");
      const parsed = JSON.parse(text.replace(/```json|```/g, "").trim());
      if (Array.isArray(parsed) && parsed.length > 0) setRecipes(parsed);
    } catch (e) { console.error("AI Error:", e); }
    setLoading(false);
  };

  const addToShopping = (recipe) => {
    setShopping(s => [{ id: Date.now(), name: `Für: ${recipe.name}`, amount: "", done: false, cat: "Rezept" }, ...s]);
    setTab("shopping");
  };

  return (
    <div style={{ fontFamily: "'DM Sans', 'Helvetica Neue', Arial, sans-serif", background: C.cream, minHeight: "100vh", maxWidth: 430, margin: "0 auto", display: "flex", flexDirection: "column", position: "relative" }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&display=swap'); * { box-sizing: border-box; } p, h2, h3 { margin: 0; } button { font-family: inherit; }`}</style>
      <div style={{ background: C.white, borderBottom: `1px solid ${C.border}`, padding: "14px 20px 12px", position: "sticky", top: 0, zIndex: 10 }}>
        <p style={{ fontSize: 20, fontWeight: 700, color: C.dark }}>{TITLES[tab]}</p>
      </div>
      <div style={{ flex: 1, overflowY: "auto", paddingBottom: 80 }}>
        {tab === "home"     && <HomeScreen recipes={recipes} pantry={pantry} loading={loading} onLoadAI={loadAI} onAddToShopping={addToShopping} />}
        {tab === "pantry"   && <PantryScreen pantry={pantry} setPantry={setPantry} />}
        {tab === "shopping" && <ShoppingScreen shopping={shopping} setShopping={setShopping} />}
        {tab === "planner"  && <PlannerScreen week={week} setWeek={setWeek} recipes={recipes} />}
        {tab === "social"   && <SocialScreen liked={liked} setLiked={setLiked} />}
      </div>
      <div style={{ position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)", width: "100%", maxWidth: 430, background: C.white, borderTop: `1px solid ${C.border}`, display: "flex", zIndex: 20 }}>
        {TABS.map(({ id, icon: Icon, label }) => {
          const active = tab === id;
          return (
            <button key={id} onClick={() => setTab(id)} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "10px 0 8px", cursor: "pointer", color: active ? C.amber : C.muted, background: "none", border: "none", gap: 4, transition: "color 0.15s" }}>
              <Icon size={20} />
              <span style={{ fontSize: 10, fontWeight: active ? 700 : 400 }}>{label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
