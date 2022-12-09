#!/bin/bash
declare -i steps=1
possibles=()
display() {
  clear
  echo "Ход № $steps"
  H="-----------------"
  B="+---------------+"
  S="%s\n|%3s|%3s|%3s|%3s|\n"
  printf $S $B ${T[0]:-"."} ${T[1]:-"."} ${T[2]:-"."} ${T[3]:-"."}
  printf $S $H ${T[4]:-"."} ${T[5]:-"."} ${T[6]:-"."} ${T[7]:-"."}
  printf $S $H ${T[8]:-"."} ${T[9]:-"."} ${T[10]:-"."} ${T[11]:-"."}
  printf $S $H ${T[12]:-"."} ${T[13]:-"."} ${T[14]:-"."} ${T[15]:-"."}
  echo $B
  if [[ "$#" -ne 0 ]]; then
    echo "Неверный ход!"
    echo "Невозможно костяшку $1 передвинуть на пустую ячейку."
    printf 'Можно выбрать: %s\n' "$(
      IFS=,
      printf '%s' "${possibles[*]}"
    )"
    possibles=()
  fi
}

init_game() {
  T=()
  EMPTY=
  RANDOM=$RANDOM
  for i in {1..15}; do
    j=$((RANDOM % 16))
    while [[ ${T[j]} != "" ]]; do
      j=$((RANDOM % 16))
    done
    T[j]=$i
  done
  for i in {0..15}; do
    [[ ${T[i]} == "" ]] && EMPTY=$i
  done
  display
}

swap() {
  T[$EMPTY]=${T[$1]}
  T[$1]=""
  EMPTY=$1
}

check_win() {
  for i in {0..14}; do
    if [ "${T[i]}" != "$(($i + 1))" ]; then
      return
    fi
  done
  display
  echo "Вы собрали головоломку за $steps ходов."
  exit
}

start_game() {
  while :; do
    down_index=$(($EMPTY + 4))
    if [[ $EMPTY -lt 12 ]]; then
      down_value=${T[$(($down_index))]}
      possibles+=(${down_value})
    else
      down_value=16
    fi
    up_index=$(($EMPTY - 4))
    [ $EMPTY -gt 3 ] && up_value=${T[$(($up_index))]}
    if [[ $EMPTY -gt 3 ]]; then
      up_value=${T[$(($up_index))]}
      possibles+=(${up_value})
    else
      up_value=16
    fi

    COL=$(($EMPTY % 4))

    left_index=$(($EMPTY - 1))
    if [[ $COL -gt 0 ]]; then
      left_value=${T[$(($left_index))]}
      possibles+=(${left_value})
    else
      left_value=16
    fi

    right_index=$(($EMPTY + 1))
    if [[ $COL -lt 3 ]]; then
      right_value=${T[$((right_index))]}
      possibles+=(${right_value})
    else
      right_value=16
    fi

    read -p "Ваш ход (q - выход): " answer
    case "${answer}" in
    "${up_value}")
      swap $up_index
      steps+=1
      ;;
    "${right_value}")
      swap $right_index
      steps+=1
      ;;
    "${down_value}")
      swap $down_index
      steps+=1
      ;;
    "${left_value}")
      swap $left_index
      steps+=1
      ;;
    q)
      exit
      ;;
    *)
      display $answer
      continue
      ;;
    esac
    possibles=()
    check_win
    display
  done
}

init_game
start_game
