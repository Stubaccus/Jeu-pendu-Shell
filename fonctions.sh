#!/bin/bash

# Fonction pour lire un mot aléatoire du fichier input.txt et supprimer les espaces/sauts de ligne
get_random_word() {
    local file="input.txt"
    local line_count=$(wc -l < "$file")
    local random_line=$((RANDOM % line_count + 1))
    local word=$(sed "${random_line}q;d" "$file" | tr -d '[:space:]')
    echo "$word"
}


# Fonction pour initialiser le mot à deviner et afficher des tirets
initialize_game() {
    local word="$1"
    local word_length=${#word}
    local hidden_word=$(printf '_%.0s' $(seq 1 $word_length))
    echo "$hidden_word"
}

# Fonction pour vérifier si la lettre est dans le mot
check_letter() {
    local letter="$1"
    local word="$2"
    local hidden_word="$3"
    local new_hidden_word=""

    for i in $(seq 0 $((${#word} - 1))); do
        if [[ "${word:$i:1}" == "$letter" ]]; then
            new_hidden_word+="$letter"
        else
            new_hidden_word+="${hidden_word:$i:1}"
        fi
    done
    echo "$new_hidden_word"
}

# Fonction récursive pour compter les occurrences d'une lettre dans un mot
count_occurrences() {
    local letter="$1"
    local word="$2"
    local index="$3"
    local length=${#word}

    # Condition d'arrêt : si on a atteint la fin du mot
    if [[ $index -ge $length ]]; then
        echo 0
        return
    fi

    # Vérifier si la lettre courante correspond à la lettre recherchée
    if [[ "${word:$index:1}" == "$letter" ]]; then
        echo $((1 + $(count_occurrences "$letter" "$word" $((index + 1)))))
    else
        echo $(count_occurrences "$letter" "$word" $((index + 1)))
    fi
}
