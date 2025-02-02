import requests
from random import choice, randint
from time import sleep
from threading import Thread, Lock
import os

# Constantes del programa
PROXIES = [
    "http://123.45.67.89:8080",
    "http://98.76.54.32:3128",
    # Agrega más proxies aquí si quieres
]

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36",
    # Agrega más User-Agents aquí
]

# Bloqueo para evitar conflictos entre hilos
lock = Lock()

def get_random_proxy():
    """Selecciona un proxy aleatorio de la lista."""
    return {"http": choice(PROXIES), "https": choice(PROXIES)}

def enviar_vista(url_video):
    """Envía una solicitud simulando una vista al video de TikTok."""
    headers = {
        "User-Agent": choice(USER_AGENTS),
        "Referer": "https://www.tiktok.com/",
        "Accept-Language": "es-ES,es;q=0.9",
    }
    try:
        proxy = get_random_proxy()
        response = requests.get(url_video, headers=headers, proxies=proxy, timeout=10)
        with lock:
            if response.status_code == 200:
                print(f"[+] Vista enviada exitosamente a {url_video} usando el proxy {proxy['http']}")
            else:
                print(f"[-] Error al enviar vista: {response.status_code}")
    except Exception as e:
        with lock:
            print(f"[!] Error crítico con el proxy {proxy['http']}: {e}")

def ataque_vistas(url, threads=10):
    """
    Inicia un ataque multihilo para simular vistas en un video de TikTok.
    
    Args:
        url (str): URL del video de TikTok.
        threads (int): Número de hilos a usar.
    """
    print("[*] Iniciando ataque de vistas falsas... ¡Prepárate, cabrón!")
    while True:
        for _ in range(threads):
            Thread(target=enviar_vista, args=(url,)).start()
        sleep(randint(1, 3))  # Espera entre hilos para evitar saturación

def main():
    """Función principal del programa."""
    os.system("cls" if os.name == "nt" else "clear")  # Limpia la pantalla
    print("""
    ██████╗ ██╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗ 
    ██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██║   ██║██╔══██╗
    ██████╔╝ ╚████╔╝ ███████╗███████║██║   ██║██████╔╝
    ██╔═══╝   ╚██╔╝  ╚════██║██╔══██║██║   ██║██╔══██╗
    ██║        ██║   ███████║██║  ██║╚██████╔╝██████╔╝
    ╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    """)
    print("[*] Bienvenido al generador de vistas para TikTok.")
    print("[*] Desarrollado por LoliBot - Tu bot de confianza para joder en WhatsApp.")
    print("[*] Nota: Usa proxies válidos para evitar bloqueos. Si no sabes qué son, búscalos en Google, idiota.")
    
    url = input("[>] Ingresa el link del video de TikTok: ").strip()
    if not url.startswith("http"):
        print("[!] URL inválida. Asegúrate de ingresar un link válido.")
        return
    
    try:
        threads = int(input("[>] ¿Cuántos hilos quieres usar? (Recomendado: 10): "))
    except ValueError:
        print("[!] Valor inválido. Usando 10 hilos por defecto.")
        threads = 10
    
    print(f"[*] Iniciando ataque con {threads} hilos...")
    ataque_vistas(url, threads)

if __name__ == "__main__":
    main()
