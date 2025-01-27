#!/bin/bash

source ./fonctions.sh  

# Fonction pour afficher le menu et gérer la navigation
display_menu() {
    local options=("Jouer" "Quitter")
    local choice=0
    while true; do
        clear
        echo "+------------------------------------------------------------+"
        echo "+             Bienvenue dans le jeu du pendu !               +"
        echo "+            Utilisez les flèches pour naviguer              +"
        echo "+                 Entrée pour valider.                       +"
        echo "+------------------------------------------------------------+"

        for i in "${!options[@]}"; do
            if [[ $i -eq $choice ]]; then
                echo "            > ${options[$i]}"
            else
                echo "              ${options[$i]}"
            fi
        done

        # Lire l'entrée utilisateur (flèches haut/bas et touche entrée)
        read -sn1 input
        case "$input" in
            $'\x1b')  # Si c'est une séquence d'échappement
                read -sn2 -t 0.1 input # Lire la suite de la séquence
                if [[ $input == "[A" ]]; then
                    ((choice--))
                    if [[ $choice -lt 0 ]]; then
                        choice=$((${#options[@]} - 1))
                    fi
                elif [[ $input == "[B" ]]; then
                    ((choice++))
                    if [[ $choice -ge ${#options[@]} ]]; then
                        choice=0
                    fi
                fi
                ;;
            "")  # Entrée
                if [[ $choice -eq 0 ]]; then
                    return 0  # Jouer
                else
                    return 1  # Quitter
                fi
                ;;
        esac
    done
}

# Afficher le menu principal
if display_menu; then
    # Si "Jouer" est sélectionné
    echo "Lancement du jeu..."
    word=$(get_random_word)
    hidden_word=$(initialize_game "$word")
    attempts=6
    guessed_letters=()
    msg_rep=""

    while [[ "$hidden_word" != "$word" && $attempts -gt 0 ]]; do
        clear
        echo "$msg_rep"
        echo "Mot à deviner : $hidden_word"
        echo "Nombre de tentatives restantes : $attempts"
        while true; do
            read -p "Proposez une lettre : " letter
                
            if [[ " ${guessed_letters[*]} " == *" $letter "* ]]; then
                echo "Erreur : Vous avez déjà proposé la lettre '$letter'."
            elif [[ "$letter" =~ ^[a-z\-]$ ]]; then
                guessed_letters+=("$letter")
                break
            else
                echo "Erreur : veuillez entrer une seule lettre valide (a-z)."
            fi
        done

        # Utilisation de la fonction récursive pour compter les occurrences
        occurrences=$(count_occurrences "$letter" "$word" 0)

        if [[ $occurrences -gt 0 ]]; then
            msg_rep="La lettre '$letter' apparaît $occurrences fois."
            hidden_word=$(check_letter "$letter" "$word" "$hidden_word")
        else
            msg_rep="Mauvaise lettre !"
            ((attempts--))
        fi
    done

    if [[ "$hidden_word" == "$word" ]]; then
        echo "Félicitations ! Vous avez trouvé le mot : $word"
    else
        echo "Dommage ! Le mot était : $word"
    fi
else
    echo "Vous avez quitté le jeu. À bientôt !"
    exit 0
fi