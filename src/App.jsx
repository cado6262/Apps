import { useState } from "react";
import { Home, Flame, ShoppingCart, Calendar, Users, Clock, Plus, X, Check, Sparkles, Loader, Search, Heart, Star, ChevronDown, ChevronUp, Store, ShieldCheck } from "lucide-react";

const C = {
  amber:"#E8901A", amberBg:"#FFF3E6", dark:"#1C1208",
  cream:"#F8F3EB", green:"#3D7A1E", greenBg:"#ECF5E3",
  white:"#FFFFFF", muted:"#8B7355", border:"#EDE4D3",
  special:"#C4621A", specialBg:"#FEF0E0",
};

const RECIPES_DEFAULT = [
  { id:1, name:"Miso-Ramen mit Shiitake",    time:35, match:95, uses:["Miso Paste","Fischsauce"], cat:"Japanisch", emoji:"🍜", batch:false, desc:"Umami-reiche Brühe mit frischen Shiitake-Pilzen" },
  { id:2, name:"Miso-Aubergine & Sesamreis", time:40, match:92, uses:["Miso Paste"],               cat:"Japanisch", emoji:"🍆", batch:true,  desc:"Glasierte Aubergine auf fluffigem Sesamreis" },
  { id:3, name:"Linsen-Dhal mit Tamarinde",  time:30, match:88, uses:["Linsen","Tamarinde"],       cat:"Indisch",   emoji:"🍛", batch:true,  desc:"Cremiges Dhal mit würziger Tamarinden-Note" },
  { id:4, name:"Sumach-Hähnchen auf Reis",   time:45, match:84, uses:["Sumach"],                   cat:"Arabisch",  emoji:"🍗", batch:false, desc:"Orientalisches Hähnchen mit Sumach-Würze" },
];

const PANTRY_DEFAULT = [
  { id:1, name:"Miso Paste",  special:true,  amount:"200g",    bestBefore:"2026-08-29", openedOn:"2026-08-14", consumeBy:"2026-08-29" },
  { id:2, name:"Fischsauce",  special:true,  amount:"300ml" },
  { id:3, name:"Sumach",      special:true,  amount:"50g" },
  { id:4, name:"Tamarinde",   special:true,  amount:"100g",    bestBefore:"2026-08-26" },
  { id:5, name:"Knoblauch",   special:false, amount:"1 Knolle" },
  { id:6, name:"Olivenöl",    special:false, amount:"500ml" },
  { id:7, name:"Pasta",       special:false, amount:"500g" },
  { id:8, name:"Zwiebeln",    special:false, amount:"5 Stück" },
  { id:9, name:"Linsen",      special:false, amount:"400g" },
  { id:10, name:"Tomaten",    special:false, amount:"4 Stück", bestBefore:"2026-08-23" },
];

const SHOPPING_DEFAULT = [
  { id:1, name:"Ramen Nudeln",      amount:"200g",   done:false, aisle:"Nudeln & Reis",   recipeId:1, recipeName:"Miso-Ramen mit Shiitake",   recipeEmoji:"🍜" },
  { id:2, name:"Shiitake Pilze",    amount:"150g",   done:false, aisle:"Obst & Gemüse",   recipeId:1, recipeName:"Miso-Ramen mit Shiitake",   recipeEmoji:"🍜" },
  { id:3, name:"Frühlingszwiebeln", amount:"1 Bund", done:true,  aisle:"Obst & Gemüse",   recipeId:1, recipeName:"Miso-Ramen mit Shiitake",   recipeEmoji:"🍜" },
  { id:4, name:"Tofu",              amount:"400g",   done:false, aisle:"Kühl & Käse",     recipeId:null },
  { id:5, name:"Hähnchenbrust",     amount:"500g",   done:false, aisle:"Fleisch & Fisch", recipeId:null },
  { id:6, name:"Kokosmilch",        amount:"400ml",  done:false, aisle:"Konserven",        recipeId:null },
];

const BASICS_DEFAULT = [
  { id:1, name:"Zwiebeln",    available:true },
  { id:2, name:"Knoblauch",   available:true },
  { id:3, name:"Olivenöl",    available:true },
  { id:4, name:"Salz",        available:true },
  { id:5, name:"Pfeffer",     available:true },
  { id:6, name:"Butter",      available:false },
  { id:7, name:"Eier",        available:true },
];

const STORES_DEFAULT = [
  { id:1, name:"Rewe",  aisles:["Obst & Gemüse","Fleisch & Fisch","Kühl & Käse","Tiefkühl","Konserven","Nudeln & Reis","Backwaren","Getränke","Sonstiges"] },
  { id:2, name:"Edeka", aisles:["Obst & Gemüse","Fleisch & Fisch","Kühl & Käse","Tiefkühl","Konserven","Nudeln & Reis","Backwaren","Getränke","Sonstiges"] },
  { id:3, name:"Lidl",  aisles:["Obst & Gemüse","Fleisch & Fisch","Kühl & Käse","Tiefkühl","Konserven","Nudeln & Reis","Backwaren","Getränke","Sonstiges"] },
];

const WEEK_DEFAULT = [
  { day:"Mo", recipe:"Linsen-Dhal",    emoji:"🍛" },
  { day:"Di", recipe:null,             emoji:null },
  { day:"Mi", recipe:"Miso-Ramen",     emoji:"🍜" },
  { day:"Do", recipe:null,             emoji:null },
  { day:"Fr", recipe:"Bolognese",      emoji:"🍝" },
  { day:"Sa", recipe:"Sumach-Hähnchen",emoji:"🍗" },
  { day:"So", recipe:null,             emoji:null },
];

const SOCIAL = [
  { id:1, initials:"LK", name:"Lena K.",   color:"#E8901A", action:"kocht gerade",    dish:"Marokkanisches Lamm-Tajine",       emoji:"🫕", likes:5, time:"10 Min" },
  { id:2, initials:"JM", name:"Jonas M.",  color:"#3D7A1E", action:"hat eingefroren", dish:"Bolognese (8 Portionen)",          emoji:"🍝", likes:3, time:"2 Std", frozen:true },
  { id:3, initials:"MT", name:"Mia & Tom", color:"#C4621A", action:"laden ein",       dish:"Gemeinsam Kochen – Samstag Abend", emoji:"🎉", likes:0, time:"1 Tag", invite:true },
  { id:4, initials:"SP", name:"Sarah P.",  color:"#7B5EA7", action:"hat gekocht",     dish:"Pad Thai mit Erdnüssen",           emoji:"🍜", likes:8, time:"3 Std" },
];

// ── Helpers ──────────────────────────────────────────────────────────────────
function getDailyRecipe(recipes) {
  const now = new Date();
  const day = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 86400000);
  return recipes[day % recipes.length];
}

function dateStatus(item) {
  const ref = item.consumeBy || item.bestBefore;
  if (!ref) return "none";
  const days = Math.floor((new Date(ref) - new Date()) / 86400000);
  if (days < 0) return "expired";
  if (days <= 2) return "critical";
  if (days <= 7) return "warning";
  return "ok";
}

function dateStatusStyle(status) {
  const map = { none:{ color:"#CCC", bg:"#F5F5F5" }, ok:{ color:"#3D7A1E", bg:"#ECF5E3" },
    warning:{ color:"#E8901A", bg:"#FFF3E6" }, critical:{ color:"#C4621A", bg:"#FEF0E0" }, expired:{ color:"#CC3333", bg:"#FFE8E8" }};
  return map[status] || map.none;
}

function dateLabel(status) {
  return { none:"", ok:"ok", warning:"bald", critical:"dringend", expired:"abgelaufen" }[status] || "";
}

function uniqueOrdered(arr) { return [...new Set(arr)]; }

// ── Rezept des Tages ─────────────────────────────────────────────────────────
function RecipeOfTheDay({ recipe, onShop }) {
  return (
    <div style={{ borderRadius:20, overflow:"hidden", marginBottom:20, boxShadow:"0 6px 28px rgba(28,18,8,0.15)" }}>
      <div style={{ background:"#2A1A07", padding:"10px 18px", display:"flex", alignItems:"center", gap:7 }}>
        <Star size={12} color="#E8901A" fill="#E8901A" />
        <span style={{ fontSize:10, fontWeight:800, color:"#E8901A", letterSpacing:1.2 }}>REZEPT DES TAGES</span>
      </div>
      <div style={{ background:"linear-gradient(160deg,#2E1F0A 0%,#3D2910 100%)", padding:"22px 20px 20px" }}>
        <div style={{ fontSize:64, textAlign:"center", lineHeight:1, marginBottom:14, filter:"drop-shadow(0 4px 12px rgba(0,0,0,0.4))" }}>{recipe.emoji}</div>
        <div style={{ textAlign:"center" }}>
          <div style={{ display:"flex", justifyContent:"center", gap:6, marginBottom:10 }}>
            <span style={{ fontSize:10, fontWeight:700, color:"#E8901A", background:"rgba(232,144,26,0.18)", padding:"3px 10px", borderRadius:20 }}>{recipe.cat?.toUpperCase()}</span>
            {recipe.batch && <span style={{ fontSize:10, fontWeight:700, color:"#6FCF4A", background:"rgba(111,207,74,0.15)", padding:"3px 10px", borderRadius:20 }}>❄ BATCH</span>}
          </div>
          <h2 style={{ margin:"0 0 8px", fontSize:21, fontWeight:800, color:"#FFF", lineHeight:1.25 }}>{recipe.name}</h2>
          <p style={{ margin:"0 0 18px", fontSize:13, color:"rgba(255,255,255,0.55)", lineHeight:1.5 }}>{recipe.desc}</p>
          <div style={{ display:"flex", justifyContent:"center", gap:28, marginBottom:20 }}>
            <div style={{ textAlign:"center" }}>
              <div style={{ fontSize:20, fontWeight:800, color:"#FFF" }}>{recipe.time}</div>
              <div style={{ fontSize:10, color:"rgba(255,255,255,0.4)", letterSpacing:0.5 }}>MINUTEN</div>
            </div>
            <div style={{ width:1, background:"rgba(255,255,255,0.12)" }} />
            <div style={{ textAlign:"center" }}>
              <div style={{ fontSize:20, fontWeight:800, color:recipe.match>90?"#6FCF4A":"#E8901A" }}>{recipe.match}%</div>
              <div style={{ fontSize:10, color:"rgba(255,255,255,0.4)", letterSpacing:0.5 }}>VORRAT</div>
            </div>
          </div>
          {recipe.uses?.length > 0 && (
            <div style={{ display:"flex", justifyContent:"center", flexWrap:"wrap", gap:6, marginBottom:18 }}>
              {recipe.uses.map(u => <span key={u} style={{ fontSize:11, fontWeight:700, color:"#FFB347", background:"rgba(255,179,71,0.15)", padding:"4px 12px", borderRadius:20 }}>✦ {u}</span>)}
            </div>
          )}
          <div style={{ display:"flex", gap:10 }}>
            <button onClick={() => onShop(recipe)} style={{ flex:1, background:"#E8901A", color:"#fff", border:"none", borderRadius:12, padding:13, fontSize:14, fontWeight:700, cursor:"pointer" }}>+ Einkaufsliste</button>
            <button style={{ flex:1, background:"rgba(255,255,255,0.1)", color:"#FFF", border:"1px solid rgba(255,255,255,0.15)", borderRadius:12, padding:13, fontSize:14, fontWeight:600, cursor:"pointer" }}>Rezept →</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Recipe Card (kompakt) ────────────────────────────────────────────────────
function RecipeCard({ r, rank, onShop }) {
  return (
    <div style={{ background:C.white, borderRadius:14, border:`1px solid ${C.border}`, marginBottom:10, overflow:"hidden" }}>
      <div style={{ padding:"13px 15px", display:"flex", gap:12 }}>
        <div style={{ fontSize:38, lineHeight:1, flexShrink:0 }}>{r.emoji}</div>
        <div style={{ flex:1 }}>
          <div style={{ display:"flex", flexWrap:"wrap", gap:5, marginBottom:5 }}>
            <span style={{ fontSize:9, fontWeight:700, color:C.muted, background:"#F0EBE2", padding:"2px 7px", borderRadius:20 }}>{r.cat?.toUpperCase()}</span>
            {r.batch && <span style={{ fontSize:9, fontWeight:700, color:C.green, background:C.greenBg, padding:"2px 7px", borderRadius:20 }}>❄ BATCH</span>}
            {rank===0 && <span style={{ fontSize:9, fontWeight:700, color:C.amber, background:C.amberBg, padding:"2px 7px", borderRadius:20 }}>★ TOP</span>}
          </div>
          <div style={{ fontSize:15, fontWeight:700, color:C.dark }}>{r.name}</div>
          <div style={{ fontSize:11, color:C.muted, marginTop:2 }}>{r.desc}</div>
        </div>
      </div>
      <div style={{ padding:"0 15px 8px", display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ flex:1 }}>
          <div style={{ display:"flex", justifyContent:"space-between", fontSize:10, color:C.muted, marginBottom:4 }}>
            <span>Vorratstreffer</span>
            <strong style={{ color:r.match>90?C.green:C.amber }}>{r.match}%</strong>
          </div>
          <div style={{ background:"#EDE4D3", borderRadius:3, height:4 }}>
            <div style={{ background:r.match>90?C.green:C.amber, width:r.match+"%", height:4, borderRadius:3 }} />
          </div>
        </div>
        <div style={{ fontSize:11, color:C.muted, display:"flex", alignItems:"center", gap:3 }}><Clock size={11}/>{r.time} Min</div>
      </div>
      {r.uses?.length>0 && (
        <div style={{ padding:"0 15px 8px", display:"flex", flexWrap:"wrap", gap:5 }}>
          {r.uses.map(u => <span key={u} style={{ fontSize:9, fontWeight:700, color:C.special, background:C.specialBg, padding:"2px 8px", borderRadius:20 }}>✦ {u}</span>)}
        </div>
      )}
      <div style={{ padding:"8px 15px 13px", display:"flex", gap:8 }}>
        <button onClick={onShop} style={{ flex:1, background:C.amber, color:"#fff", border:"none", borderRadius:9, padding:"9px", fontSize:12, fontWeight:600, cursor:"pointer" }}>+ Einkaufsliste</button>
        <button style={{ background:"#F0EBE2", color:C.muted, border:"none", borderRadius:9, padding:"9px 13px", fontSize:12, cursor:"pointer" }}>Rezept →</button>
      </div>
    </div>
  );
}

// ── Home Screen ──────────────────────────────────────────────────────────────
function HomeScreen({ recipes, pantry, loading, onLoadAI, onAddToShopping }) {
  const h = new Date().getHours();
  const greeting = h<12?"Guten Morgen 👋":h<17?"Guten Mittag 👋":"Guten Abend 👋";
  const specials = pantry.filter(p=>p.special);
  return (
    <div style={{ padding:16 }}>
      <div style={{ marginBottom:20 }}>
        <p style={{ margin:0, fontSize:13, color:C.muted }}>{greeting}</p>
        <h2 style={{ margin:"3px 0 0", fontSize:23, fontWeight:800, color:C.dark }}>Was kochen wir heute?</h2>
      </div>
      <RecipeOfTheDay recipe={getDailyRecipe(recipes)} onShop={onAddToShopping} />
      {specials.length>0 && (
        <div style={{ background:C.specialBg, border:`1px solid ${C.special}33`, borderRadius:12, padding:"10px 14px", marginBottom:18, display:"flex", gap:10 }}>
          <span style={{ fontSize:16 }}>✦</span>
          <div>
            <div style={{ fontSize:10, fontWeight:700, color:C.special, letterSpacing:0.5 }}>SONDERZUTATEN — BALD VERBRAUCHEN</div>
            <div style={{ fontSize:11, color:C.muted, marginTop:1 }}>{specials.map(s=>s.name).join(" · ")}</div>
          </div>
        </div>
      )}
      <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", marginBottom:12 }}>
        <div>
          <div style={{ fontSize:10, fontWeight:700, color:C.muted, letterSpacing:0.5 }}>PASSEND ZU DEINEM VORRAT</div>
          <div style={{ fontSize:16, fontWeight:700, color:C.dark }}>KI-Vorschläge</div>
        </div>
        <button onClick={onLoadAI} disabled={loading} style={{ background:loading?"#C4A882":C.dark, color:"#fff", border:"none", borderRadius:12, padding:"9px 14px", fontSize:12, fontWeight:700, cursor:loading?"wait":"pointer", display:"flex", alignItems:"center", gap:7 }}>
          {loading?<Loader size={13}/>:<Sparkles size={13}/>}{loading?"Lädt…":"Neu laden"}
        </button>
      </div>
      {recipes.map((r,i) => <RecipeCard key={r.id} r={r} rank={i} onShop={()=>onAddToShopping(r)} />)}
    </div>
  );
}

// ── Makros Screen ────────────────────────────────────────────────────────────
function MacrosScreen({ goal, setGoal }) {
  const macros = [
    { key:"kcal",    label:"Kalorien",      unit:"kcal", color:"#E8901A", today:1240 },
    { key:"protein", label:"Eiweiß",        unit:"g",    color:"#3D7A1E", today:89 },
    { key:"fat",     label:"Fett",          unit:"g",    color:"#7B5EA7", today:42 },
    { key:"carbs",   label:"Kohlenhydrate", unit:"g",    color:"#4B9CD3", today:138 },
  ];
  return (
    <div style={{ padding:16 }}>
      {/* Apple Health Banner */}
      <div style={{ background:C.white, border:`1px solid #FF375F33`, borderRadius:14, padding:"12px 14px", marginBottom:16, display:"flex", alignItems:"center", gap:12 }}>
        <span style={{ fontSize:24 }}>❤️</span>
        <div style={{ flex:1 }}>
          <div style={{ fontSize:13, fontWeight:700, color:C.dark }}>Apple Health verbinden</div>
          <div style={{ fontSize:11, color:C.muted }}>MacroFactor · Yazio · MyFitnessPal → automatisch importieren</div>
        </div>
        <button style={{ background:"#FF375F", color:"#fff", border:"none", borderRadius:10, padding:"7px 12px", fontSize:12, fontWeight:700, cursor:"pointer" }}>Verbinden</button>
      </div>

      {/* Heute */}
      <div style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:14, padding:14, marginBottom:16 }}>
        <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:12 }}>HEUTE GEGESSEN</div>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr 1fr", gap:8 }}>
          {macros.map(m => {
            const pct = Math.min(m.today/goal[m.key]*100, 100);
            return (
              <div key={m.key} style={{ textAlign:"center" }}>
                <div style={{ position:"relative", width:52, height:52, margin:"0 auto 6px" }}>
                  <svg width={52} height={52} style={{ transform:"rotate(-90deg)" }}>
                    <circle cx={26} cy={26} r={21} fill="none" stroke={m.color+"22"} strokeWidth={5}/>
                    <circle cx={26} cy={26} r={21} fill="none" stroke={m.color} strokeWidth={5}
                      strokeDasharray={`${2*Math.PI*21*pct/100} ${2*Math.PI*21}`} strokeLinecap="round"/>
                  </svg>
                  <div style={{ position:"absolute", top:"50%", left:"50%", transform:"translate(-50%,-50%)", fontSize:10, fontWeight:800, color:C.dark }}>{m.today}</div>
                </div>
                <div style={{ fontSize:9, fontWeight:700, color:m.color }}>{m.label}</div>
                <div style={{ fontSize:9, color:C.muted }}>/ {goal[m.key]}{m.unit}</div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Tagesziele */}
      <div style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:14, padding:14, marginBottom:16 }}>
        <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:10 }}>MEINE TAGESZIELE</div>
        {macros.map(m => (
          <div key={m.key} style={{ marginBottom:10 }}>
            <div style={{ display:"flex", justifyContent:"space-between", fontSize:12, marginBottom:4 }}>
              <span style={{ color:C.dark, fontWeight:500 }}>{m.label}</span>
              <span style={{ color:C.muted }}>{m.today} / {goal[m.key]} {m.unit}</span>
            </div>
            <div style={{ background:"#EDE4D3", borderRadius:3, height:5 }}>
              <div style={{ background:m.color, width:Math.min(m.today/goal[m.key]*100,100)+"%", height:5, borderRadius:3 }} />
            </div>
          </div>
        ))}
      </div>

      {/* Rezept nach Makros */}
      <button style={{ width:"100%", background:C.dark, color:"#fff", border:"none", borderRadius:14, padding:14, fontSize:15, fontWeight:700, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:10, boxSizing:"border-box" }}>
        <Sparkles size={15}/> Rezept nach Makros vorschlagen
      </button>

      {/* App-Import */}
      <div style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:14, padding:14, marginTop:16 }}>
        <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:8 }}>APP-IMPORT EINRICHTEN</div>
        {[["MacroFactor","Einstellungen > Apple Health aktivieren"],["Yazio","Profil > Verbundene Apps > Apple Health"],["MyFitnessPal","Mehr > Apps & Geräte > Apple Health"]].map(([app,step]) => (
          <div key={app} style={{ marginBottom:8 }}>
            <div style={{ fontSize:12, fontWeight:700, color:C.dark }}>{app}</div>
            <div style={{ fontSize:11, color:C.muted }}>{step}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Küche Screen (Vorrat + Einkauf) ─────────────────────────────────────────
function KucheScreen({ pantry, setPantry, shopping, setShopping, basics, setBasics, stores, setStores, selectedStore, setSelectedStore, recipes }) {
  const [segment, setSegment] = useState(0);
  return (
    <div style={{ display:"flex", flexDirection:"column", height:"100%" }}>
      {/* Segmented Control */}
      <div style={{ background:C.white, borderBottom:`1px solid ${C.border}`, padding:"10px 16px", display:"flex", gap:8 }}>
        {["Vorrat","Einkaufsliste"].map((label,i) => (
          <button key={i} onClick={()=>setSegment(i)} style={{ flex:1, background:segment===i?C.dark:"#F0EBE2", color:segment===i?"#fff":C.muted, border:"none", borderRadius:10, padding:"9px", fontSize:13, fontWeight:700, cursor:"pointer" }}>
            {label}
          </button>
        ))}
      </div>
      <div style={{ flex:1, overflowY:"auto" }}>
        {segment===0
          ? <PantryContent pantry={pantry} setPantry={setPantry}/>
          : <ShoppingContent shopping={shopping} setShopping={setShopping} basics={basics} setBasics={setBasics}
              stores={stores} setStores={setStores} selectedStore={selectedStore} setSelectedStore={setSelectedStore} recipes={recipes}/>}
      </div>
    </div>
  );
}

// ── Vorrat ───────────────────────────────────────────────────────────────────
function PantryContent({ pantry, setPantry }) {
  const [search, setSearch] = useState("");
  const [newName, setNewName] = useState("");
  const [newAmt, setNewAmt] = useState("");
  const [editItem, setEditItem] = useState(null);
  const filtered = pantry.filter(p=>!search||p.name.toLowerCase().includes(search.toLowerCase()));
  const specials = filtered.filter(p=>p.special);
  const regular  = filtered.filter(p=>!p.special);
  const expiring = pantry.filter(p=>["critical","expired"].includes(dateStatus(p)));

  const toggle = id => setPantry(p=>p.map(i=>i.id===id?{...i,special:!i.special}:i));
  const remove = id => setPantry(p=>p.filter(i=>i.id!==id));
  const add = () => {
    if (!newName.trim()) return;
    setPantry(p=>[...p,{id:Date.now(),name:newName.trim(),special:false,amount:newAmt.trim()||"vorhanden"}]);
    setNewName(""); setNewAmt("");
  };

  return (
    <div style={{ padding:16 }}>
      {expiring.length>0 && (
        <div style={{ background:"#FEF0E0", border:"1px solid #C4621A44", borderRadius:12, padding:"10px 14px", marginBottom:12, display:"flex", gap:8 }}>
          <span style={{ fontSize:14 }}>⚠️</span>
          <div>
            <div style={{ fontSize:10, fontWeight:700, color:"#C4621A" }}>BALD ABLAUFEND</div>
            <div style={{ fontSize:11, color:C.muted }}>{expiring.map(e=>e.name).join(", ")}</div>
          </div>
        </div>
      )}
      <div style={{ display:"flex", alignItems:"center", background:C.white, border:`1px solid ${C.border}`, borderRadius:12, padding:"8px 14px", gap:8, marginBottom:12 }}>
        <Search size={14} color={C.muted}/>
        <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Suchen..." style={{ border:"none", outline:"none", flex:1, fontSize:14, background:"transparent", color:C.dark }}/>
      </div>
      <div style={{ display:"flex", gap:8, marginBottom:16 }}>
        <input value={newName} onChange={e=>setNewName(e.target.value)} onKeyDown={e=>e.key==="Enter"&&add()} placeholder="Neue Zutat..." style={{ flex:2, border:`1px solid ${C.border}`, borderRadius:10, padding:"10px 12px", fontSize:14, outline:"none", background:C.white, color:C.dark }}/>
        <input value={newAmt}  onChange={e=>setNewAmt(e.target.value)}  onKeyDown={e=>e.key==="Enter"&&add()} placeholder="Menge" style={{ flex:1, border:`1px solid ${C.border}`, borderRadius:10, padding:"10px 8px", fontSize:14, outline:"none", background:C.white, color:C.dark }}/>
        <button onClick={add} style={{ background:C.amber, color:"#fff", border:"none", borderRadius:10, padding:"10px 16px", fontSize:18, fontWeight:700, cursor:"pointer" }}>+</button>
      </div>

      {specials.length>0 && <>
        <div style={{ fontSize:11, fontWeight:700, color:C.special, letterSpacing:0.5, marginBottom:8 }}>✦ SONDERZUTATEN</div>
        {specials.map(item=><PantryRow key={item.id} item={item} onToggle={()=>toggle(item.id)} onRemove={()=>remove(item.id)} onEdit={()=>setEditItem(item)}/>)}
        <div style={{ height:8 }}/>
      </>}
      <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:8 }}>VORRAT</div>
      {regular.map(item=><PantryRow key={item.id} item={item} onToggle={()=>toggle(item.id)} onRemove={()=>remove(item.id)} onEdit={()=>setEditItem(item)}/>)}

      {editItem && <DateEditModal item={editItem} onSave={updated=>{setPantry(p=>p.map(i=>i.id===updated.id?updated:i));setEditItem(null);}} onClose={()=>setEditItem(null)}/>}
    </div>
  );
}

function PantryRow({ item, onToggle, onRemove, onEdit }) {
  const status = dateStatus(item);
  const st = dateStatusStyle(status);
  return (
    <div onClick={onEdit} style={{ background:item.special?C.specialBg:C.white, border:`1px solid ${item.special?C.special+"44":C.border}`, borderRadius:12, padding:"10px 14px", marginBottom:8, display:"flex", alignItems:"center", gap:12, cursor:"pointer" }}>
      <div style={{ flex:1 }}>
        <div style={{ display:"flex", alignItems:"center", gap:6, marginBottom:2 }}>
          <span style={{ fontWeight:600, color:C.dark, fontSize:14 }}>{item.name}</span>
          {status!=="none" && <span style={{ fontSize:9, fontWeight:700, color:st.color, background:st.bg, padding:"2px 6px", borderRadius:8 }}>{dateLabel(status)}</span>}
        </div>
        <div style={{ fontSize:11, color:C.muted }}>
          {item.amount}
          {item.bestBefore && ` · Haltbar bis ${new Date(item.bestBefore).toLocaleDateString("de")}`}
          {item.consumeBy  && ` · Verbrauchen bis ${new Date(item.consumeBy).toLocaleDateString("de")}`}
        </div>
      </div>
      {status==="none" && <span style={{ fontSize:16, color:"#CCC" }}>📅</span>}
      <button onClick={e=>{e.stopPropagation();onToggle();}} style={{ fontSize:18, background:"none", border:"none", cursor:"pointer", color:item.special?C.special:"#CCC" }}>✦</button>
      <button onClick={e=>{e.stopPropagation();onRemove();}} style={{ background:"none", border:"none", cursor:"pointer", color:"#CCC", display:"flex" }}><X size={14}/></button>
    </div>
  );
}

function DateEditModal({ item, onSave, onClose }) {
  const [form, setForm] = useState({ ...item });
  const fields = [
    { key:"bestBefore",  label:"Haltbar bis (ungeöffnet)",  icon:"📦" },
    { key:"openedOn",    label:"Geöffnet am",                icon:"🔓" },
    { key:"consumeBy",   label:"Verbrauchen bis (geöffnet)", icon:"⏱" },
    { key:"purchasedOn", label:"Gekauft am",                 icon:"🛒" },
  ];
  return (
    <div style={{ position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", zIndex:100, display:"flex", alignItems:"flex-end" }} onClick={onClose}>
      <div style={{ background:C.white, borderRadius:"20px 20px 0 0", padding:20, width:"100%", boxSizing:"border-box", maxHeight:"85vh", overflowY:"auto" }} onClick={e=>e.stopPropagation()}>
        <div style={{ fontSize:17, fontWeight:700, color:C.dark, marginBottom:4 }}>{item.name}</div>
        <div style={{ fontSize:12, color:C.muted, marginBottom:16 }}>Alle Felder sind optional — trage ein was du weißt.</div>
        <div style={{ display:"flex", gap:8, marginBottom:16 }}>
          <input value={form.name} onChange={e=>setForm(f=>({...f,name:e.target.value}))} placeholder="Name" style={{ flex:2, border:`1px solid ${C.border}`, borderRadius:10, padding:"9px 12px", fontSize:14, outline:"none" }}/>
          <input value={form.amount||""} onChange={e=>setForm(f=>({...f,amount:e.target.value}))} placeholder="Menge" style={{ flex:1, border:`1px solid ${C.border}`, borderRadius:10, padding:"9px 8px", fontSize:14, outline:"none" }}/>
        </div>
        {fields.map(({key,label,icon}) => (
          <div key={key} style={{ marginBottom:12 }}>
            <div style={{ fontSize:12, fontWeight:600, color:C.dark, marginBottom:6 }}>{icon} {label}</div>
            <div style={{ display:"flex", gap:8 }}>
              <input type="date" value={form[key]||""} onChange={e=>setForm(f=>({...f,[key]:e.target.value||null}))}
                style={{ flex:1, border:`1px solid ${C.border}`, borderRadius:10, padding:"9px 12px", fontSize:14, outline:"none", color:C.dark }}/>
              {form[key] && <button onClick={()=>setForm(f=>({...f,[key]:null}))} style={{ background:"#F0EBE2", border:"none", borderRadius:10, padding:"9px 12px", cursor:"pointer", color:C.muted }}><X size={14}/></button>}
            </div>
          </div>
        ))}
        <div style={{ display:"flex", gap:8, marginTop:8 }}>
          <button onClick={onClose} style={{ flex:1, background:"#F0EBE2", color:C.muted, border:"none", borderRadius:12, padding:12, fontSize:14, fontWeight:600, cursor:"pointer" }}>Abbrechen</button>
          <button onClick={()=>onSave(form)} style={{ flex:1, background:C.amber, color:"#fff", border:"none", borderRadius:12, padding:12, fontSize:14, fontWeight:700, cursor:"pointer" }}>Speichern</button>
        </div>
      </div>
    </div>
  );
}

// ── Einkaufsliste ────────────────────────────────────────────────────────────
function ShoppingContent({ shopping, setShopping, basics, setBasics, stores, setStores, selectedStore, setSelectedStore }) {
  const [newItem, setNewItem] = useState("");
  const [expanded, setExpanded] = useState(new Set());
  const [showBasics, setShowBasics] = useState(false);
  const [showStores, setShowStores] = useState(false);
  const [newBasic, setNewBasic] = useState("");

  const store = stores.find(s=>s.id===selectedStore);
  const doneCount = shopping.filter(s=>s.done).length;
  const progress = shopping.length ? doneCount/shopping.length : 0;

  // Rezept-Gruppen
  const recipeIds = [...new Set(shopping.filter(s=>s.recipeId).map(s=>s.recipeId))];
  const recipeGroups = recipeIds.map(rid => ({
    id:rid,
    name: shopping.find(s=>s.recipeId===rid)?.recipeName||"Rezept",
    emoji: shopping.find(s=>s.recipeId===rid)?.recipeEmoji||"🍽",
    items: shopping.filter(s=>s.recipeId===rid),
  }));

  // Einzelartikel sortiert nach Gang
  const standalone = shopping.filter(s=>!s.recipeId);
  const aisleOrder = store?.aisles||[];
  const sortedStandalone = [...standalone].sort((a,b)=>{
    const ai=aisleOrder.indexOf(a.aisle); const bi=aisleOrder.indexOf(b.aisle);
    return (ai===-1?999:ai)-(bi===-1?999:bi);
  });
  const aisles = [...new Set(sortedStandalone.map(s=>s.aisle))];

  const toggle = id => setShopping(s=>s.map(i=>i.id===id?{...i,done:!i.done}:i));
  const remove = id => setShopping(s=>s.filter(i=>i.id!==id));
  const removeRecipe = rid => setShopping(s=>s.filter(i=>i.recipeId!==rid));
  const add = () => {
    if (!newItem.trim()) return;
    setShopping(s=>[...s,{id:Date.now(),name:newItem.trim(),amount:"",done:false,aisle:"Sonstiges",recipeId:null}]);
    setNewItem("");
  };
  const toggleExpand = id => setExpanded(e=>{ const n=new Set(e); n.has(id)?n.delete(id):n.add(id); return n; });

  return (
    <div style={{ padding:16 }}>
      {/* Supermarkt-Selector */}
      <button onClick={()=>setShowStores(true)} style={{ width:"100%", background:C.white, border:`1px solid ${C.border}`, borderRadius:12, padding:"10px 14px", marginBottom:12, display:"flex", alignItems:"center", gap:8, cursor:"pointer", boxSizing:"border-box" }}>
        <Store size={14} color={C.amber}/>
        <span style={{ flex:1, fontSize:14, fontWeight:600, color:C.dark, textAlign:"left" }}>{store?.name||"Supermarkt wählen"}</span>
        <ChevronDown size={14} color={C.muted}/>
      </button>

      {/* Fortschritt */}
      <div style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:14, padding:14, marginBottom:12 }}>
        <div style={{ display:"flex", justifyContent:"space-between", fontSize:13, marginBottom:8 }}>
          <span style={{ fontWeight:600, color:C.dark }}>Fortschritt</span>
          <span style={{ color:C.muted }}>{doneCount}/{shopping.length} erledigt</span>
        </div>
        <div style={{ background:"#EDE4D3", borderRadius:4, height:6 }}>
          <div style={{ background:C.green, width:Math.round(progress*100)+"%", height:6, borderRadius:4, transition:"width 0.3s" }}/>
        </div>
      </div>

      {/* Neue Zutat */}
      <div style={{ display:"flex", gap:8, marginBottom:16 }}>
        <input value={newItem} onChange={e=>setNewItem(e.target.value)} onKeyDown={e=>e.key==="Enter"&&add()} placeholder="Artikel hinzufügen..."
          style={{ flex:1, border:`1px solid ${C.border}`, borderRadius:10, padding:"10px 12px", fontSize:14, outline:"none", background:C.white, color:C.dark }}/>
        <button onClick={add} style={{ background:C.amber, color:"#fff", border:"none", borderRadius:10, padding:"10px 18px", fontSize:18, fontWeight:700, cursor:"pointer" }}>+</button>
      </div>

      {/* Rezept-Sektionen */}
      {recipeGroups.length>0 && <>
        <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:8 }}>REZEPTE</div>
        {recipeGroups.map(g => {
          const done = g.items.filter(i=>i.done).length;
          const all  = done===g.items.length;
          const open = expanded.has(g.id);
          return (
            <div key={g.id} style={{ background:all?C.greenBg:C.amberBg, border:`1px solid ${C.border}`, borderRadius:14, marginBottom:8, overflow:"hidden" }}>
              <div onClick={()=>toggleExpand(g.id)} style={{ padding:"12px 14px", display:"flex", alignItems:"center", gap:10, cursor:"pointer" }}>
                <span style={{ fontSize:22 }}>{g.emoji}</span>
                <div style={{ flex:1 }}>
                  <div style={{ fontSize:14, fontWeight:700, color:C.dark }}>{g.name}</div>
                  <div style={{ fontSize:11, color:C.muted }}>{done}/{g.items.length} erledigt</div>
                </div>
                {all && <Check size={18} color={C.green}/>}
                {open?<ChevronUp size={14} color={C.muted}/>:<ChevronDown size={14} color={C.muted}/>}
                <button onClick={e=>{e.stopPropagation();removeRecipe(g.id);}} style={{ background:"none", border:"none", cursor:"pointer", color:"#CCC", display:"flex", padding:4 }}><X size={14}/></button>
              </div>
              {open && g.items.map(item => (
                <div key={item.id} style={{ background:C.white, borderTop:`1px solid ${C.border}`, padding:"10px 14px", display:"flex", alignItems:"center", gap:12, opacity:item.done?0.5:1 }}>
                  <button onClick={()=>toggle(item.id)} style={{ width:22, height:22, borderRadius:6, border:`2px solid ${item.done?C.green:"#DDD"}`, background:item.done?C.green:"transparent", display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer", flexShrink:0 }}>
                    {item.done&&<Check size={11} color="#fff"/>}
                  </button>
                  <span style={{ flex:1, fontSize:14, color:C.dark, textDecoration:item.done?"line-through":"none" }}>{item.name}</span>
                  {item.amount&&<span style={{ fontSize:11, color:C.muted }}>{item.amount}</span>}
                </div>
              ))}
            </div>
          );
        })}
        <div style={{ height:8 }}/>
      </>}

      {/* Einzelartikel nach Gang */}
      {sortedStandalone.length>0 && <>
        <div style={{ fontSize:11, fontWeight:700, color:C.muted, letterSpacing:0.5, marginBottom:8 }}>ARTIKEL</div>
        {aisles.map(aisle => (
          <div key={aisle} style={{ marginBottom:12 }}>
            <div style={{ fontSize:10, fontWeight:700, color:C.muted, opacity:0.6, letterSpacing:0.5, marginBottom:6 }}>{aisle.toUpperCase()}</div>
            {sortedStandalone.filter(s=>s.aisle===aisle).map(item => (
              <div key={item.id} style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:12, padding:"10px 14px", marginBottom:6, display:"flex", alignItems:"center", gap:12, opacity:item.done?0.5:1 }}>
                <button onClick={()=>toggle(item.id)} style={{ width:24, height:24, borderRadius:8, border:`2px solid ${item.done?C.green:"#DDD"}`, background:item.done?C.green:"transparent", display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer", flexShrink:0 }}>
                  {item.done&&<Check size={12} color="#fff"/>}
                </button>
                <div style={{ flex:1 }}>
                  <div style={{ fontSize:14, fontWeight:500, color:C.dark, textDecoration:item.done?"line-through":"none" }}>{item.name}</div>
                  {item.amount&&<div style={{ fontSize:11, color:C.muted }}>{item.amount}</div>}
                </div>
                <button onClick={()=>remove(item.id)} style={{ background:"none", border:"none", cursor:"pointer", color:"#CCC", display:"flex" }}><X size={14}/></button>
              </div>
            ))}
          </div>
        ))}
      </>}

      {/* Basics prüfen */}
      <div style={{ background:C.white, border:`1px solid ${C.border}`, borderRadius:14, overflow:"hidden", marginBottom:8 }}>
        <div onClick={()=>setShowBasics(b=>!b)} style={{ padding:"12px 14px", display:"flex", alignItems:"center", gap:10, cursor:"pointer" }}>
          <ShieldCheck size={16} color={C.muted}/>
          <span style={{ flex:1, fontSize:14, fontWeight:600, color:C.dark }}>Basics prüfen</span>
          <span style={{ fontSize:11, color:C.muted }}>Grundzutaten zuhause?</span>
          {showBasics?<ChevronUp size={14} color={C.muted}/>:<ChevronDown size={14} color={C.muted}/>}
        </div>
        {showBasics && <>
          {basics.map(b => (
            <div key={b.id} style={{ borderTop:`1px solid ${C.border}`, padding:"9px 14px", display:"flex", alignItems:"center", gap:12, opacity:b.available?0.6:1 }}>
              <button onClick={()=>setBasics(bs=>bs.map(x=>x.id===b.id?{...x,available:!x.available}:x))}
                style={{ width:22, height:22, borderRadius:"50%", border:`2px solid ${b.available?C.green:"#DDD"}`, background:b.available?C.green:"transparent", display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer", flexShrink:0 }}>
                {b.available&&<Check size={11} color="#fff"/>}
              </button>
              <span style={{ flex:1, fontSize:14, color:C.dark }}>{b.name}</span>
              {!b.available&&<span style={{ fontSize:11, fontWeight:700, color:"#CC3333" }}>fehlt</span>}
            </div>
          ))}
          <div style={{ borderTop:`1px solid ${C.border}`, padding:"8px 14px", display:"flex", gap:8 }}>
            <input value={newBasic} onChange={e=>setNewBasic(e.target.value)}
              onKeyDown={e=>{if(e.key==="Enter"&&newBasic.trim()){setBasics(b=>[...b,{id:Date.now(),name:newBasic.trim(),available:true}]);setNewBasic("");}}}
              placeholder="Basic hinzufügen..." style={{ flex:1, border:"none", outline:"none", fontSize:13, color:C.dark, background:"transparent" }}/>
            <Plus size={18} color={C.amber} style={{ cursor:"pointer" }} onClick={()=>{if(newBasic.trim()){setBasics(b=>[...b,{id:Date.now(),name:newBasic.trim(),available:true}]);setNewBasic("");}}}/>
          </div>
        </>}
      </div>

      {/* Store Sheet */}
      {showStores && (
        <div style={{ position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", zIndex:100, display:"flex", alignItems:"flex-end" }} onClick={()=>setShowStores(false)}>
          <div style={{ background:C.white, borderRadius:"20px 20px 0 0", padding:20, width:"100%", boxSizing:"border-box" }} onClick={e=>e.stopPropagation()}>
            <div style={{ fontSize:17, fontWeight:700, color:C.dark, marginBottom:16 }}>Supermarkt wählen</div>
            {stores.map(s => (
              <div key={s.id} onClick={()=>{setSelectedStore(s.id);setShowStores(false);}}
                style={{ padding:"12px 14px", borderRadius:12, marginBottom:8, background:selectedStore===s.id?C.amberBg:C.cream, border:`1px solid ${selectedStore===s.id?C.amber:C.border}`, display:"flex", alignItems:"center", gap:10, cursor:"pointer" }}>
                <Store size={16} color={selectedStore===s.id?C.amber:C.muted}/>
                <span style={{ flex:1, fontSize:15, fontWeight:600, color:C.dark }}>{s.name}</span>
                {selectedStore===s.id&&<Check size={16} color={C.green}/>}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

// ── Planer ───────────────────────────────────────────────────────────────────
function PlannerScreen({ week, setWeek, recipes }) {
  return (
    <div style={{ padding:16 }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:14 }}>
        <h3 style={{ margin:0, fontSize:15, fontWeight:700, color:C.dark }}>Diese Woche</h3>
        <button onClick={()=>setWeek(w=>w.map((d,i)=>({...d,recipe:recipes[i%recipes.length]?.name||null,emoji:recipes[i%recipes.length]?.emoji||null})))}
          style={{ background:C.amber, color:"#fff", border:"none", borderRadius:10, padding:"8px 14px", fontSize:12, fontWeight:600, cursor:"pointer", display:"flex", alignItems:"center", gap:6 }}>
          <Sparkles size={12}/> KI planen
        </button>
      </div>
      {week.map((day,i) => (
        <div key={day.day} style={{ background:day.recipe?C.white:C.cream, border:`1px solid ${day.recipe?C.border:"transparent"}`, borderRadius:14, padding:"12px 16px", marginBottom:8, display:"flex", alignItems:"center", gap:14 }}>
          <div style={{ textAlign:"center", minWidth:32 }}>
            <p style={{ margin:0, fontSize:10, fontWeight:700, color:C.muted }}>{day.day}</p>
            <p style={{ margin:0, fontSize:18, fontWeight:700, color:day.recipe?C.amber:"#CCC" }}>{i+1}</p>
          </div>
          <div style={{ flex:1 }}>
            {day.recipe
              ? <p style={{ margin:0, fontSize:14, fontWeight:600, color:C.dark }}>{day.emoji} {day.recipe}</p>
              : <button onClick={()=>{const r=recipes[Math.floor(Math.random()*recipes.length)];setWeek(w=>w.map((d,idx)=>idx===i?{...d,recipe:r.name,emoji:r.emoji}:d));}}
                  style={{ background:"none", border:"none", cursor:"pointer", color:C.muted, fontSize:13, display:"flex", alignItems:"center", gap:6, padding:0 }}>
                  <Plus size={13}/> Lang drücken für Zufallsrezept
                </button>}
          </div>
          {day.recipe&&<button onClick={()=>setWeek(w=>w.map((d,idx)=>idx===i?{...d,recipe:null,emoji:null}:d))} style={{ background:"none", border:"none", cursor:"pointer", color:"#CCC", display:"flex" }}><X size={14}/></button>}
        </div>
      ))}
      <div style={{ background:C.greenBg, border:`1px solid ${C.green}33`, borderRadius:14, padding:"12px 14px", marginTop:4 }}>
        <p style={{ margin:"0 0 4px", fontSize:11, fontWeight:700, color:C.green }}>❄ BATCH COOK TIPP</p>
        <p style={{ margin:0, fontSize:12, color:C.muted }}>Linsen-Dhal und Bolognese eignen sich ideal zum Einfrieren. Koche doppelte Menge und spare 3x Zeit!</p>
      </div>
    </div>
  );
}

// ── Social ───────────────────────────────────────────────────────────────────
function SocialScreen({ liked, setLiked }) {
  return (
    <div style={{ padding:16 }}>
      <h3 style={{ margin:"0 0 14px", fontSize:15, fontWeight:700, color:C.dark }}>Was Freunde kochen</h3>
      {SOCIAL.map(post => (
        <div key={post.id} style={{ background:C.white, borderRadius:16, border:`1px solid ${C.border}`, padding:"14px 16px", marginBottom:12 }}>
          <div style={{ display:"flex", gap:12 }}>
            <div style={{ width:42, height:42, borderRadius:21, background:post.color+"20", display:"flex", alignItems:"center", justifyContent:"center", fontSize:12, fontWeight:700, color:post.color, flexShrink:0 }}>{post.initials}</div>
            <div style={{ flex:1 }}>
              <p style={{ margin:0, fontSize:14, fontWeight:700, color:C.dark }}>{post.name}</p>
              <p style={{ margin:"2px 0 0", fontSize:11, color:C.muted }}>{post.action} · vor {post.time}</p>
              <p style={{ margin:"8px 0 0", fontSize:15 }}>{post.emoji} <strong style={{ color:C.dark }}>{post.dish}</strong></p>
            </div>
          </div>
          <div style={{ display:"flex", flexWrap:"wrap", gap:8, marginTop:10 }}>
            <button onClick={()=>setLiked(l=>({...l,[post.id]:!l[post.id]}))} style={{ background:liked[post.id]?"#FFE8E8":C.cream, color:liked[post.id]?"#E33":C.muted, border:"none", borderRadius:20, padding:"6px 14px", fontSize:12, cursor:"pointer", display:"flex", alignItems:"center", gap:5 }}>
              <Heart size={12} fill={liked[post.id]?"#E33":"none"} color={liked[post.id]?"#E33":C.muted}/>{(post.likes||0)+(liked[post.id]?1:0)}
            </button>
            {post.invite?<button style={{ background:C.amber, color:"#fff", border:"none", borderRadius:20, padding:"6px 14px", fontSize:12, fontWeight:600, cursor:"pointer" }}>Zusagen →</button>
              :<button style={{ background:C.cream, color:C.muted, border:"none", borderRadius:20, padding:"6px 14px", fontSize:12, cursor:"pointer" }}>Rezept übernehmen</button>}
            {post.frozen&&<span style={{ fontSize:10, fontWeight:700, color:"#4B9CD3", background:"#E8F4FF", padding:"4px 10px", borderRadius:20, display:"flex", alignItems:"center" }}>❄ Eingefroren</span>}
          </div>
        </div>
      ))}
    </div>
  );
}

// ── Tabs ─────────────────────────────────────────────────────────────────────
const TABS = [
  { id:"home",      icon:Home,         label:"Heute" },
  { id:"macros",    icon:Flame,        label:"Makros" },
  { id:"kuche",     icon:ShoppingCart, label:"Küche" },
  { id:"planner",   icon:Calendar,     label:"Planer" },
  { id:"social",    icon:Users,        label:"Social" },
];
const TITLES = { home:"Next Cooking", macros:"Makros & Ernährung", kuche:"Küche", planner:"Wochenplan", social:"Freunde" };

// ── App ───────────────────────────────────────────────────────────────────────
export default function App() {
  const [tab, setTab]           = useState("home");
  const [pantry, setPantry]     = useState(PANTRY_DEFAULT);
  const [shopping, setShopping] = useState(SHOPPING_DEFAULT);
  const [basics, setBasics]     = useState(BASICS_DEFAULT);
  const [stores, setStores]     = useState(STORES_DEFAULT);
  const [selectedStore, setSelectedStore] = useState(STORES_DEFAULT[0].id);
  const [week, setWeek]         = useState(WEEK_DEFAULT);
  const [recipes, setRecipes]   = useState(RECIPES_DEFAULT);
  const [loading, setLoading]   = useState(false);
  const [liked, setLiked]       = useState({});
  const [goal, setGoal]         = useState({ kcal:2000, protein:150, fat:65, carbs:200 });

  const loadAI = async () => {
    setLoading(true);
    const special = pantry.filter(p=>p.special).map(p=>p.name).join(", ");
    const all = pantry.map(p=>p.name).join(", ");
    try {
      const res = await fetch("https://api.anthropic.com/v1/messages", {
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body:JSON.stringify({ model:"claude-sonnet-4-20250514", max_tokens:900,
          messages:[{role:"user",content:`Kochassistent Next Cooking. Vorrat: ${all}. Sonderzutaten: ${special}. 4 Rezepte. NUR JSON: [{"id":1,"name":"Name","time":30,"match":95,"uses":["Zutat"],"cat":"Küche","emoji":"🍜","batch":false,"desc":"Beschreibung"}]`}]})
      });
      const d = await res.json();
      const text = (d.content||[]).map(b=>b.text||"").join("");
      const parsed = JSON.parse(text.replace(/```json|```/g,"").trim());
      if (Array.isArray(parsed)&&parsed.length>0) setRecipes(parsed);
    } catch(e) { console.error(e); }
    setLoading(false);
  };

  const addToShopping = recipe => {
    setShopping(s=>[{id:Date.now(),name:`Für: ${recipe.name}`,amount:"",done:false,aisle:"Sonstiges",recipeId:recipe.id,recipeName:recipe.name,recipeEmoji:recipe.emoji},...s]);
    setTab("kuche");
  };

  return (
    <div style={{ fontFamily:"'DM Sans','Helvetica Neue',Arial,sans-serif", background:C.cream, minHeight:"100vh", maxWidth:430, margin:"0 auto", display:"flex", flexDirection:"column" }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&display=swap'); *{box-sizing:border-box;} p,h2,h3{margin:0;} button{font-family:inherit;}`}</style>
      <div style={{ background:C.white, borderBottom:`1px solid ${C.border}`, padding:"14px 20px 12px", position:"sticky", top:0, zIndex:10 }}>
        <p style={{ fontSize:20, fontWeight:700, color:C.dark }}>{TITLES[tab]}</p>
      </div>
      <div style={{ flex:1, overflowY:"auto", paddingBottom:80 }}>
        {tab==="home"    && <HomeScreen recipes={recipes} pantry={pantry} loading={loading} onLoadAI={loadAI} onAddToShopping={addToShopping}/>}
        {tab==="macros"  && <MacrosScreen goal={goal} setGoal={setGoal}/>}
        {tab==="kuche"   && <KucheScreen pantry={pantry} setPantry={setPantry} shopping={shopping} setShopping={setShopping}
            basics={basics} setBasics={setBasics} stores={stores} setStores={setStores} selectedStore={selectedStore} setSelectedStore={setSelectedStore} recipes={recipes}/>}
        {tab==="planner" && <PlannerScreen week={week} setWeek={setWeek} recipes={recipes}/>}
        {tab==="social"  && <SocialScreen liked={liked} setLiked={setLiked}/>}
      </div>
      <div style={{ position:"fixed", bottom:0, left:"50%", transform:"translateX(-50%)", width:"100%", maxWidth:430, background:C.white, borderTop:`1px solid ${C.border}`, display:"flex", zIndex:20 }}>
        {TABS.map(({id,icon:Icon,label}) => {
          const active=tab===id;
          return (
            <button key={id} onClick={()=>setTab(id)} style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", padding:"10px 0 8px", cursor:"pointer", color:active?C.amber:C.muted, background:"none", border:"none", gap:4 }}>
              <Icon size={20}/><span style={{ fontSize:10, fontWeight:active?700:400 }}>{label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
