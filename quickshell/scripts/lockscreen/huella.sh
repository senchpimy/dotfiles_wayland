#!/bin/bash

failed_errors=0  # Contador de errores fallidos sin "no-match"
no_match_errs=5

while true; do
  while true; do
      LID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
      if [[ "$LID_STATE" == "open" ]]; then
          #echo "El lid está abierto. continueando"
          break
      fi
      echo "LID"
      sleep 1
  done

  echo "reading"
  res=$(fprintd-verify)
  exit_code=$?

  echo "$res" | grep -q no-match
  val=$?  # 0 si encontró "no-match", 1 si no
  echo "$res" | grep -q "claim device"
  releaseFailed=$?

  if [[ $releaseFailed -eq 0 ]];then
    echo "Rebooted system"
    sudo /usr/bin/systemctl restart fprintd.service
    continue
  fi

  if [ $exit_code -eq 0 ]; then
      echo "El comando se ejecutó con éxito (exit code: $exit_code). Terminando el loop."
      break
  else
      error_msg="error"
      time=15
      if [[ $val -eq 0 ]]; then
          echo "$res"
          error_msg="no-match"
          time=1
          failed_errors=0  # Reinicia el contador si fue "no-match"
          ((no_match_errs++))
      else
          ((failed_errors++))
          echo "Error fallido detectado. Total consecutivos: $failed_errors"
          if [[ $failed_errors -ge 2 ]]; then
              echo "Se detectaron 2 errores fallidos consecutivos. Esperando 3 minutos."
              time=180
          fi
      fi
      echo "$error_msg"
  fi

  if [[ $no_match_errs -ge 4 ]];then
    time = 200
    echo "Too many failed attempts"
  fi


  sleep $time
done

exit $exit_code
