#!/usr/bin/env python3
"""Generate original fictional club identities from normalized, lawfully sourced CSV.
Input columns: source_id,country_code,city,region,continent,active,level.
Source club names, nicknames, crests and kit colours are deliberately ignored.
"""
import argparse, csv, hashlib, json
from pathlib import Path
PALETTES=[("#123B63","#E8F1F8","#D7A928"),("#145A45","#F4F0DF","#C65A3A"),("#6B263B","#F3E7D2","#2D526B"),("#3C3B78","#F5F2E9","#D17A32"),("#176B78","#F5F5F0","#B83B4B"),("#6A4B25","#F4EBD4","#315B45"),("#30343B","#E5E8EC","#B58A3A"),("#8A3E26","#F7E8D0","#244D68")]
SUFFIXES=["Deportivo","Atlético","Unión","Sporting","Fuerza","Horizonte","Aurora","Estrella","Marítimo","Montaña","Río","Náutico"]
def sha(s): return hashlib.sha256(s.encode()).hexdigest()
def identity(row):
    h=sha(row["source_id"]+"|"+row["country_code"])
    city=(row.get("city") or "").strip()
    region=(row.get("region") or "").strip()
    base=city or region or ("Distrito "+h[:4].upper())
    suffix=SUFFIXES[int(h[0:2],16)%len(SUFFIXES)]
    name=f"{base} {suffix}"
    if region and region.casefold()!=city.casefold() and int(h[2:4],16)%3==0:
        name=f"{base} del {region} {suffix}"
    return name,h
def crest(name,palette,h):
    p,s,a=palette
    motif=(f'<path d="M150 88V205" stroke="{a}" stroke-width="12"/>' if int(h[4:6],16)%3==0 else
           f'<path d="M88 135H212" stroke="{a}" stroke-width="12"/>' if int(h[4:6],16)%3==1 else
           f'<circle cx="150" cy="145" r="35" fill="none" stroke="{a}" stroke-width="12"/>')
    safe=name.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 340" role="img" aria-label="{safe}"><path d="M35 30H265V190Q250 275 150 320Q50 275 35 190Z" fill="{p}" stroke="{s}" stroke-width="12"/><path d="M58 52H242V185Q230 250 150 290Q70 250 58 185Z" fill="none" stroke="{a}" stroke-width="7"/>{motif}<path d="M75 75H225" stroke="{s}" stroke-width="5" opacity=".75"/></svg>'
def kits(h,p):
    p,s,a=p
    pattern=["vertical_stripes","diagonal_sash","split","hoops"][int(h[6:8],16)%4]
    return {"home":{"base_color":p,"secondary_color":s,"accent_color":a,"pattern":pattern,"manufacturer":"NOVA Original"},
      "away":{"base_color":s,"secondary_color":p,"accent_color":a,"pattern":"geometric_blocks","manufacturer":"NOVA Original"},
      "goalkeeper":{"base_color":a,"secondary_color":"#20242A","accent_color":s,"pattern":"micro_geometry","manufacturer":"NOVA Original"}}
def main():
    ap=argparse.ArgumentParser(); ap.add_argument("--input",required=True); ap.add_argument("--output",required=True); args=ap.parse_args()
    out=Path(args.output); (out/"crests").mkdir(parents=True,exist_ok=True)
    clubs=[]; used=set()
    with open(args.input,encoding="utf-8-sig",newline="") as f:
      for row in csv.DictReader(f):
        if not row.get("source_id") or not row.get("country_code"): continue
        name,h=identity(row)
        if name.casefold() in used: name+= " "+h[:4].upper()
        used.add(name.casefold())
        palette=PALETTES[int(h[8:10],16)%len(PALETTES)]
        cid="NOVA-"+row["country_code"].upper()+"-"+h[:12].upper()
        asset=f"crests/{cid}.svg"; (out/asset).write_text(crest(name,palette,h),encoding="utf-8")
        clubs.append({"id":cid,"display_name":name,"country_code":row["country_code"].upper(),
          "home_city":row.get("city",""),"home_region":row.get("region",""),"continent":row.get("continent",""),
          "active_source_record":row.get("active",""),"competition_level_source":row.get("level",""),
          "fictional":True,"identity_type":"original_procedural_club","crest_asset":asset,"kits":kits(h,palette),
          "inspiration_reference_id":row["source_id"],"source_name_excluded_from_generation":True,
          "trademark_review_status":"research_required","publication_status":"blocked_pending_review","visual_assets_original":True})
    (out/"clubs.json").write_text(json.dumps({"schema_version":1,"generated_count":len(clubs),
      "status":"draft_pending_name_and_trademark_review","clubs":clubs},ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(f"Generated {len(clubs)} fictional club drafts in {out}")
if __name__=="__main__": main()
