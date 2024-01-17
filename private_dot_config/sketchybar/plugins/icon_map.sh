icon_map() {
    case "$1" in
    "Messages")
        icon_result=":messages:"
    ;;
    "Spotify")
        icon_result=":spotify:"
    ;;
    "Emacs")
        icon_result=":emacs:"
    ;;
    "Finder")
        icon_result=":finder:"
    ;;
    "Arc")
        icon_result=":arc:"
    ;;
    "Thunderbird")
        icon_result=":thunderbird:"
    ;;
    "Calendar")
        icon_result=":calendar:"
    ;;
    "Slack")
        icon_result=":slack:"
    ;;
    "Alacritty" | "Terminal" | "kitty")
        icon_result=":terminal:"
    ;;
    *)
        icon_result=":default:"
    ;;
    esac

    echo $icon_result
}
