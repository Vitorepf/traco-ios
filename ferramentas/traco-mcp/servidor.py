#!/usr/bin/env python3
"""O companheiro no Mac: um servidor MCP só de leitura sobre a pasta do Traço.

Lê a pasta espelhada (Documents/Traço, via cabo, ou a pasta que o autor
escolheu em Perfil › Espelhar numa pasta, no iCloud Drive) e a expõe a
Claude, ChatGPT, Cursor ou qualquer cliente MCP por stdio. Nunca escreve.

Sem dependências: fala JSON-RPC 2.0 sobre stdin/stdout, como o protocolo
MCP pede (Content-Length não é exigido no transporte stdio; uma mensagem por
linha).

Uso (Claude Desktop, ~/Library/Application Support/Claude/claude_desktop_config.json):

  "traco": { "command": "python3",
             "args": ["/caminho/traco-ios/ferramentas/traco-mcp/servidor.py",
                      "/Users/voce/Library/Mobile Documents/com~apple~CloudDocs/Traço"] }

O selo vale como no app: a pasta só contém o que o app deixou sair
(expressiva em curso nunca; selada e queimada só como metadado e sentido).
"""
import json
import os
import re
import sys
from pathlib import Path

VERSAO = "0.1.0"


def pasta_padrao() -> Path:
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).expanduser()
    icloud = Path.home() / "Library/Mobile Documents/com~apple~CloudDocs/Traço"
    return icloud


class Pasta:
    def __init__(self, raiz: Path):
        self.raiz = raiz
        self.notas = raiz / "notas"

    def existe(self) -> bool:
        return self.raiz.is_dir()

    def contrato(self) -> str:
        p = self.raiz / "LEIA-ME.md"
        return p.read_text(encoding="utf-8") if p.exists() else ""

    def indice(self) -> str:
        p = self.raiz / "INDICE.md"
        return p.read_text(encoding="utf-8") if p.exists() else ""

    def corpus(self) -> str:
        p = self.raiz / "traco-corpus.md"
        return p.read_text(encoding="utf-8") if p.exists() else ""

    def arquivos(self):
        if not self.notas.is_dir():
            return []
        return sorted(self.notas.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True)

    @staticmethod
    def cabecalho(texto: str) -> dict:
        """O cabeçalho `chave: valor` entre os `---` do arquivo."""
        m = re.match(r"^---\n(.*?)\n---\n?(.*)$", texto, re.S)
        if not m:
            return {"_corpo": texto}
        campos = {}
        for linha in m.group(1).splitlines():
            if ":" in linha:
                k, v = linha.split(":", 1)
                campos[k.strip()] = v.strip()
        campos["_corpo"] = m.group(2).strip()
        return campos

    def notas_resumo(self, gesto: str | None = None, limite: int = 50):
        saida = []
        for p in self.arquivos():
            texto = p.read_text(encoding="utf-8")
            c = self.cabecalho(texto)
            if gesto and c.get("gesto", "").lower() != gesto.lower():
                continue
            primeira = next((l for l in c["_corpo"].splitlines() if l.strip()), "")
            saida.append({
                "id": p.stem,
                "gesto": c.get("gesto", ""),
                "criada": c.get("criada", ""),
                "dominio": c.get("dominio", ""),
                "estado": c.get("estado", ""),
                "sentido": c.get("sentido", ""),
                "titulo": primeira[:120],
            })
            if len(saida) >= limite:
                break
        return saida

    def nota(self, id_: str) -> str | None:
        seguro = re.sub(r"[^a-f0-9\-]", "", id_.lower())
        p = self.notas / f"{seguro}.md"
        return p.read_text(encoding="utf-8") if p.exists() else None

    def buscar(self, termo: str, limite: int = 20):
        t = termo.lower()
        saida = []
        for p in self.arquivos():
            texto = p.read_text(encoding="utf-8")
            baixo = texto.lower()
            i = baixo.find(t)
            if i < 0:
                continue
            ini = max(0, i - 80)
            saida.append({"id": p.stem, "trecho": texto[ini:i + len(termo) + 80].replace("\n", " ")})
            if len(saida) >= limite:
                break
        return saida

    def semana(self, dias: int = 7):
        """O que a mente deixou no papel nos últimos `dias`: por forma, destaques,
        decisões (escolha e o que se esperava) e as linhas de sentido."""
        import datetime as dt
        corte = (dt.datetime.now() - dt.timedelta(days=dias)).date().isoformat()
        por_forma: dict = {}
        destaques, decisoes, sentidos = [], [], []
        for p in self.arquivos():
            c = self.cabecalho(p.read_text(encoding="utf-8"))
            criada = c.get("criada", "")[:10]
            if criada < corte:
                continue
            g = c.get("gesto", "") or "sem forma"
            if c.get("estado", "") in ("em curso",):
                continue
            por_forma[g] = por_forma.get(g, 0) + 1
            if g == "Destaque" and c.get("unica"):
                destaques.append(c["unica"])
            if g == "Decisão":
                decisoes.append({"escolha": c.get("escolha", ""), "espero": c.get("espero", ""), "aconteceu": c.get("aconteceu", "")})
            if c.get("sentido"):
                sentidos.append(c["sentido"])
        return {"desde": corte, "por_forma": por_forma, "destaques": destaques, "decisoes": decisoes, "sentidos": sentidos}

    def sentidos(self, limite: int = 20):
        saida = []
        for p in self.arquivos():
            c = self.cabecalho(p.read_text(encoding="utf-8"))
            s = c.get("sentido", "")
            if s:
                saida.append({"id": p.stem, "criada": c.get("criada", ""), "sentido": s})
            if len(saida) >= limite:
                break
        return saida


FERRAMENTAS = [
    {"name": "traco_contrato", "description": "O contrato do app (LEIA-ME.md): o que a pasta é e o que a IA pode fazer com ela.",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "traco_indice", "description": "O índice das notas (INDICE.md).",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "traco_notas", "description": "Lista as notas mais recentes com gesto, data, domínio, sentido e primeira linha.",
     "inputSchema": {"type": "object", "properties": {
         "gesto": {"type": "string", "description": "Só esta forma (WOOP, Se–então, Especificação, Nota permanente, Destaque, Destilar, Palavra)"},
         "limite": {"type": "integer", "default": 50}}}},
    {"name": "traco_nota", "description": "Uma nota inteira, em Markdown, pelo id.",
     "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "traco_buscar", "description": "Busca lexical nas notas; devolve trechos com o id.",
     "inputSchema": {"type": "object", "properties": {"termo": {"type": "string"}, "limite": {"type": "integer", "default": 20}}, "required": ["termo"]}},
    {"name": "traco_sentidos", "description": "As linhas de sentido (o que o autor escreveu ao fechar cada expressiva), das mais recentes para trás.",
     "inputSchema": {"type": "object", "properties": {"limite": {"type": "integer", "default": 20}}}},
    {"name": "traco_corpus", "description": "O corpus inteiro (traco-corpus.md), com o contrato no topo. Grande.",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "traco_semana", "description": "A revisão da semana: notas por forma nos últimos sete dias, destaques, decisões, o que ficou claro.",
     "inputSchema": {"type": "object", "properties": {"dias": {"type": "integer", "default": 7}}}},
]


def chamar(pasta: Pasta, nome: str, args: dict) -> str:
    if not pasta.existe():
        return f"A pasta do Traço não está em {pasta.raiz}. Escolha uma pasta no app (Perfil › Espelhar numa pasta) ou passe o caminho como argumento."
    if nome == "traco_contrato":
        return pasta.contrato() or "Sem LEIA-ME.md ainda."
    if nome == "traco_indice":
        return pasta.indice() or "Sem INDICE.md ainda."
    if nome == "traco_notas":
        return json.dumps(pasta.notas_resumo(args.get("gesto"), int(args.get("limite", 50))), ensure_ascii=False, indent=1)
    if nome == "traco_nota":
        return pasta.nota(str(args.get("id", ""))) or "Não há nota com esse id."
    if nome == "traco_buscar":
        return json.dumps(pasta.buscar(str(args.get("termo", "")), int(args.get("limite", 20))), ensure_ascii=False, indent=1)
    if nome == "traco_sentidos":
        return json.dumps(pasta.sentidos(int(args.get("limite", 20))), ensure_ascii=False, indent=1)
    if nome == "traco_corpus":
        return pasta.corpus() or "Sem traco-corpus.md ainda."
    if nome == "traco_semana":
        return json.dumps(pasta.semana(int(args.get("dias", 7))), ensure_ascii=False, indent=1)
    raise KeyError(nome)


def responder(pasta: Pasta, msg: dict):
    metodo = msg.get("method")
    id_ = msg.get("id")
    if metodo == "initialize":
        return {"jsonrpc": "2.0", "id": id_, "result": {
            "protocolVersion": msg.get("params", {}).get("protocolVersion", "2024-11-05"),
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "traco", "version": VERSAO}}}
    if metodo == "ping":
        return {"jsonrpc": "2.0", "id": id_, "result": {}}
    if metodo == "tools/list":
        return {"jsonrpc": "2.0", "id": id_, "result": {"tools": FERRAMENTAS}}
    if metodo == "tools/call":
        p = msg.get("params", {})
        try:
            texto = chamar(pasta, p.get("name", ""), p.get("arguments") or {})
            return {"jsonrpc": "2.0", "id": id_, "result": {"content": [{"type": "text", "text": texto}]}}
        except KeyError:
            return {"jsonrpc": "2.0", "id": id_, "error": {"code": -32601, "message": "ferramenta desconhecida"}}
    if metodo and metodo.startswith("notifications/"):
        return None
    if id_ is not None:
        return {"jsonrpc": "2.0", "id": id_, "error": {"code": -32601, "message": f"método desconhecido: {metodo}"}}
    return None


def servir(pasta: Pasta):
    for linha in sys.stdin:
        linha = linha.strip()
        if not linha:
            continue
        try:
            msg = json.loads(linha)
        except json.JSONDecodeError:
            continue
        resp = responder(pasta, msg)
        if resp is not None:
            sys.stdout.write(json.dumps(resp, ensure_ascii=False) + "\n")
            sys.stdout.flush()


def autoteste():
    """python3 servidor.py --autoteste: monta uma pasta falsa e conversa consigo."""
    import tempfile
    raiz = Path(tempfile.mkdtemp()) / "Traço"
    (raiz / "notas").mkdir(parents=True)
    (raiz / "LEIA-ME.md").write_text("# contrato\nsó ler.\n", encoding="utf-8")
    (raiz / "notas" / "aaaa-1.md").write_text(
        "---\ngesto: WOOP\ncriada: 2026-09-02\nsentido: o medo era de decepcionar\n---\nquero correr todo dia\n", encoding="utf-8")
    (raiz / "notas" / "bbbb-2.md").write_text(
        "---\ngesto: Destaque\ncriada: 2026-09-01\n---\nterminar o relatório\n", encoding="utf-8")
    pasta = Pasta(raiz)
    r = responder(pasta, {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    assert r["result"]["serverInfo"]["name"] == "traco"
    r = responder(pasta, {"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
    assert len(r["result"]["tools"]) == 8
    r = responder(pasta, {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "traco_notas", "arguments": {"gesto": "woop"}}})
    lista = json.loads(r["result"]["content"][0]["text"])
    assert len(lista) == 1 and lista[0]["titulo"] == "quero correr todo dia"
    r = responder(pasta, {"jsonrpc": "2.0", "id": 4, "method": "tools/call", "params": {"name": "traco_buscar", "arguments": {"termo": "relatório"}}})
    assert "bbbb-2" in r["result"]["content"][0]["text"]
    r = responder(pasta, {"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "traco_sentidos", "arguments": {}}})
    assert "decepcionar" in r["result"]["content"][0]["text"]
    r = responder(pasta, {"jsonrpc": "2.0", "id": 6, "method": "tools/call", "params": {"name": "traco_nota", "arguments": {"id": "../etc/passwd"}}})
    assert "Não há nota" in r["result"]["content"][0]["text"]
    r = responder(pasta, {"jsonrpc": "2.0", "id": 7, "method": "tools/call", "params": {"name": "inexistente", "arguments": {}}})
    assert "error" in r
    import datetime as dt
    hoje = dt.date.today().isoformat()
    (raiz / "notas" / "cccc-3.md").write_text(
        f"---\ngesto: Destaque\ncriada: {hoje}\nunica: terminar o relatório\n---\nlista do dia\n", encoding="utf-8")
    r = responder(pasta, {"jsonrpc": "2.0", "id": 8, "method": "tools/call", "params": {"name": "traco_semana", "arguments": {}}})
    semana = json.loads(r["result"]["content"][0]["text"])
    assert semana["destaques"] == ["terminar o relatório"] and semana["por_forma"].get("Destaque", 0) >= 1
    print("autoteste ok")


if __name__ == "__main__":
    if "--autoteste" in sys.argv:
        autoteste()
    else:
        servir(Pasta(pasta_padrao()))
