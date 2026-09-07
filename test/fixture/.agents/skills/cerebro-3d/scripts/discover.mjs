import {promises as fs} from 'node:fs';
import path from 'node:path';
import os from 'node:os';
// Lista caminhos candidatos (sem ler o conteúdo) para as categorias do cérebro 3D.
const at=process.argv.indexOf('--root');
const root=path.resolve(at>=0?process.argv[at+1]:process.cwd());
const candidates=[];
async function add(label,p,type='markdown'){try{const stat=await fs.stat(p);candidates.push({label,path:p,type,isDirectory:stat.isDirectory()});}catch{}}
for(const [label,p] of [
  ['Contexto','contexto'],['Wiki','wiki'],['Referências','referencias'],['Projetos','projetos'],['Decisões','decisoes'],
  ['Fontes','fontes'],['Entrevistas','entrevistas'],['Reuniões','reunioes'],['Rotinas','rotinas'],
  ['Skills','.claude/skills'],['Agentes','.claude/agents'],
  // Nomes em inglês, caso o cérebro use outra convenção.
  ['Context','context'],['Meetings','meetings'],['Projects','projects'],['References','references']
]) await add(label,path.join(root,p));
await add('Memória do Codex',path.join(process.env.CODEX_HOME||path.join(os.homedir(),'.codex'),'memories'),'codex-memory');
const claude=path.join(os.homedir(),'.claude','projects');
const encoded=root.replace(/[^a-zA-Z0-9]/g,'-').toLowerCase();
try{for(const entry of await fs.readdir(claude,{withFileTypes:true}))if(entry.isDirectory() && entry.name.toLowerCase()===encoded)await add('Memória do Claude',path.join(claude,entry.name,'memory'));}catch{}
console.log(JSON.stringify({root,candidates,note:'Só caminhos candidatos. Pergunte ao usuário o nome do cérebro e as categorias; confirme quais caminhos incluir antes de ler memória externa. Acrescente categorias personalizadas se precisar.'},null,2));
