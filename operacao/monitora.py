#!/usr/bin/env python3
"""Monitora RTT, linha de base de ate 30 amostras boas e perda 3/10.
Uso: python3 operacao/monitora.py 10.20.2.10
"""
import re, subprocess, sys, time, statistics
from collections import deque
ORIGEM = ['docker','exec','clab-rede-caixa1']
DESTINO = sys.argv[1] if len(sys.argv) > 1 else '10.20.2.10'
boas=deque(maxlen=30)
perdas=deque(maxlen=10)

def medir():
 r=subprocess.run(ORIGEM+['ping','-c','1','-W','1',DESTINO],capture_output=True,text=True)
 m=re.search(r'time=([\d.]+)',r.stdout)
 return float(m.group(1)) if m else None

while True:
 rtt=medir()
 perdas.append(rtt is None)
 alerta_perda=len(perdas)==10 and sum(perdas)>=3
 if len(boas)>=10 and rtt is not None:
  media=statistics.mean(boas)
  desvio=statistics.pstdev(boas)
  limite=media+max(3*desvio,2)
  alerta_rtt=rtt>limite
 else:
  alerta_rtt=False
 alerta=alerta_perda or alerta_rtt
 print(time.strftime('%H:%M:%S'), 'perdido' if rtt is None else f'{rtt:.1f} ms', 'ANOMALIA' if alerta else '',flush=True)
 if rtt is not None and not alerta:
  boas.append(rtt)
 time.sleep(1)
