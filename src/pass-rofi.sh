#!/usr/bin/env bash

PASSRC=${PASSRC:-"$HOME/.passrc"}
PASS_STORE=${PASS_STORE:-"$HOME/.pass/"}

PASSWORD_STORE="$PASS_STORE/passwords/"
OTP_STORE="$PASS_STORE/otp/"
RECUVA_STORE="$PASS_STORE/recovery/"

if [ ! -d "$PASS_STORE" ]; then
  notify-send -u normal "Pass: Error" "No PASS_STORE found!"
fi

for dir in "$PASSWORD_STORE" "$OTP_STORE" "$RECUVA_STORE"; do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
done

ENTROPY_SALT=$(sed -n 's/^ENTROPY_SALT=//p' "$PASSRC")
ENTROPY_ITERATION=$(sed -n 's/^ENTROPY_ITERATION=//p' "$PASSRC")
ENTROPY_AMPLIFICATION=$(sed -n 's/^ENTROPY_AMPLIFICATION=//p' "$PASSRC")

if ! command -v rofi &>/dev/null; then
  echo "rofi could not be found. Please install it."
  exit 1
fi

_rofi() {
  rofi -dmenu -i -no-levenshtein-sort -width 1000 "$@"
}

error() {
  notify-send -u normal "Pass: Error" "An unknown error occurred!"
}

switch_mode="Ctrl+s"
addpass="Alt+a"
delete="Ctrl-x"
close="Ctrl-z"
close_tomb="Ctrl-Z"
edit="Ctrl-y"
recuva_mode="Ctrl-r"

help_color="#7c5cff"
div_color="#334433"
label="#f067fc"

function deleteMenu() {
  delask=$(echo -e "1. Yes\n2. No" | _rofi -p '> ' -mesg "<span color='${label}'>Really delete</span> <span color='${help_color}'>$menu?</span>")
  val=$?
  if [[ $val -eq 1 ]]; then
    notify-send -u low "Pass: Delete" "Cancelled!"
    mode=pass main
  fi
  if [[ "$delask" == "1. Yes" ]]; then
    case "$mode" in
    pass)
      pass -n -f rm "$menu" || error
      ;;
    otp)
      pass-otp -n -f rm "$menu" || error
      ;;
    esac
  fi
  mode=pass main
}

function addMenu() {
  addmenu=$(echo | _rofi -p '> ' -mesg "<span color='${label}'>Usage: </span>Insert directory/passname")
  val=$?
  if [[ $val -eq 1 ]]; then
    notify-send -u low "Pass: Add" "Cancelled!"
    mode=pass main
  elif [[ $val -eq 0 ]]; then
    case "$mode" in
    pass)
      pass -n generate "$addmenu" 72 || error
      ;;
    otp)
      otp_key=$(zenity --entry --title="Enter OTP Key" --text="Please enter your OTP Key. No spaces allowed:")
      pass-otp -n generate "$addmenu" "$otp_key" || error
      ;;
    esac
  fi
  mode=pass main
}

function editMenu() {
  term=${TERMCMD:-kitty}
  case "$mode" in
  otp)
    $term -- sh -c "pass-otp edit \"$menu\""
    ;;
  recuva)
    $term -- sh -c "pass-otp recuva \"$menu\""
    ;;
  esac
}

main() {
  case "$mode" in
  pass)
    HELP="<span color='${label}'>Modes: </span><span color='${help_color}'>${switch_mode}</span>: toggle (pass/otp) <span color='${div_color}'>|</span> <span color='${help_color}'>${recuva_mode}</span>: toggle recuva
<span color='${label}'>Close: </span> <span color='${help_color}'>${close}</span>: close key <span color='${div_color}'>|</span> <span color='${help_color}'>${close_tomb}</span>: close tomb
<span color='${label}'>Actions: </span> <span color='${help_color}'>${addpass}</span>: Add <span color='${div_color}'>|</span> <span color='${help_color}'>${delete}</span>: Delete"
    passdir="$PASSWORD_STORE"
    ;;
  otp)
    HELP="<span color='${label}'>Modes: </span><span color='${help_color}'>${switch_mode}</span>: toggle (pass/otp) <span color='${div_color}'>|</span> <span color='${help_color}'>${recuva_mode}</span>: toggle recuva
<span color='${label}'>Close: </span> <span color='${help_color}'>${close}</span>: close key <span color='${div_color}'>|</span> <span color='${help_color}'>${close_tomb}</span>: close tomb
<span color='${label}'>Actions: </span><span color='${help_color}'>${addpass}</span>: Add <span color='${div_color}'>|</span> <span color='${help_color}'>${delete}</span>: Delete <span color='${div_color}'>|</span> <span color='${help_color}'>${edit}</span>: Edit"
    passdir="$OTP_STORE"
    ;;
  recuva)
    HELP="<span color='${label}'>Modes: </span><span color='${help_color}'>${switch_mode}</span>: toggle (pass/otp) <span color='${div_color}'>|</span> <span color='${help_color}'>${recuva_mode}</span>: toggle recuva
<span color='${label}'>Close: </span> <span color='${help_color}'>${close}</span>: close key <span color='${div_color}'>|</span> <span color='${help_color}'>${close_tomb}</span>: close tomb"
    passdir="$RECUVA_STORE"
    ;;
  esac

  pass=$(find "$passdir" -type f -name '*.age' -printf '%P\n' | awk -F. '{print $1}')
  menu=$(echo "${pass}" | _rofi -p "$mode" -mesg "${HELP}" -kb-custom-1 "${addpass}" -kb-custom-2 "${switch_mode}" -kb-custom-3 "${delete}" -kb-custom-4 "${edit}" -kb-custom-5 "${recuva_mode}" -kb-custom-6 "${close}" -kb-custom-7 "${close_tomb}")

  val=$?
  notify-send "$val"
  case "$val" in
  1) exit ;;
  12) deleteMenu ;;
  11) # Modes
    case "$mode" in
    otp) mode=pass ;;
    pass) mode=otp ;;
    recuva) mode=pass ;;
    esac
    main
    ;;
  10) addMenu ;;
  13) editMenu ;;
  14)
    mode=recuva
    main
    ;;
  15)
    pass close
    ;;
  16)
    tomb slam
    ;;
  0)
    case "$mode" in
    pass)
      if [ "$ENTROPY_AMPLIFICATION" = "true" ]; then
        pass -n -a -s "$ENTROPY_SALT" -i "$ENTROPY_ITERATION" "$menu"
      else
        pass -n cp "$menu"
      fi
      ;;
    otp)
      if [ "$ENTROPY_AMPLIFICATION" = "true" ]; then
        pass-otp -n -a -s "$ENTROPY_SALT" -i "$ENTROPY_ITERATION" cp "$menu"
      else
        pass-otp -n cp "$menu"
      fi
      ;;
    recuva)
      if [ "$ENTROPY_AMPLIFICATION" = "true" ]; then
        pass-otp -n -a -s "$ENTROPY_SALT" -i "$ENTROPY_ITERATION" recuva "$menu"
      else
        pass-otp -n recuva "$menu"
      fi
      ;;
    esac
    ;;
  esac
}

mode=pass main
