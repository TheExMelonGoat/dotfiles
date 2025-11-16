#!/usr/bin/env bash

## Theme ------------------------------------
DIR="$HOME/.config/hypr"

## Directories ------------------------------
PATH_ALAC="$DIR/alacritty"
PATH_FOOT="$DIR/foot"
PATH_MAKO="$DIR/mako"
PATH_ROFI="$DIR/rofi"
PATH_WAYB="$DIR/waybar"
PATH_WLOG="$DIR/wlogout"
PATH_WOFI="$DIR/wofi"

## Source Theme File ------------------------
CURRENT_THEME="$DIR/theme/current.bash"
DEFAULT_THEME="$DIR/theme/default.bash"

## Wallpaper Directory ----------------------
WALLDIR="$(xdg-user-dir PICTURES)/wallpapers"
INDEX_FILE="$HOME/.cache/wal_index"

## Check Wallpaper Directory ---------------
check_wallpaper() {
	if [[ -d "$WALLDIR" ]]; then
		WFILES="$(ls --format=single-column "$WALLDIR" | wc -l)"
		if [[ "$WFILES" == 0 ]]; then
			notify-send "No wallpapers in $WALLDIR"
			exit 1
		fi
	else
		mkdir -p "$WALLDIR"
		notify-send "Created $WALLDIR. Add wallpapers and re-run."
		exit 1
	fi
}

## Color Gen --------------------------------
generate_colors_matugen() {
	check_wallpaper
	mapfile -t WALLPAPERS < <(find "$WALLDIR" -type f | sort)
	TOTAL=${#WALLPAPERS[@]}

	if [[ -f "$INDEX_FILE" ]]; then
		INDEX=$(<"$INDEX_FILE")
		((INDEX++))
		[[ $INDEX -ge $TOTAL ]] && INDEX=0
	else
		INDEX=0
	fi

	echo $INDEX > "$INDEX_FILE"
	IMG="${WALLPAPERS[$INDEX]}"
	export wallpaper="$IMG"

	notify-send -t 5000 "Applying Matugen from $(basename "$IMG")"
	matugen image "$IMG" --type dark --theme-path "$DIR/theme" --no-preview
	source "$DIR/theme/colors.bash"
}

## Default Theme ----------------------------
source_default() {
	cat ${DEFAULT_THEME} > ${CURRENT_THEME}
	source ${CURRENT_THEME}
	altbackground="$(pastel color $background | pastel lighten 0.10 | pastel format hex)"
	altforeground="$(pastel color $foreground | pastel darken 0.30 | pastel format hex)"
	modbackground=($(pastel gradient -n 3 $background $altbackground | pastel format hex))
	accent="$color5"
}

## Wallpaper ---------------------------------
apply_wallpaper() {
	sed -i -e "s#WALLPAPER=.*#WALLPAPER='$wallpaper'#g" ${DIR}/scripts/wallpaper
	bash ${DIR}/scripts/wallpaper &
}


## Alacritty ---------------------------------
apply_alacritty() {
	cat > ${PATH_ALAC}/colors.toml <<- _EOF_
		[colors.primary]
		background = "${background}"
		foreground = "${foreground}"
		[colors.normal]
		black   = "${color0}"
		red     = "${color1}"
		green   = "${color2}"
		yellow  = "${color3}"
		blue    = "${color4}"
		magenta = "${color5}"
		cyan    = "${color6}"
		white   = "${color7}"
		[colors.bright]
		black   = "${color8}"
		red     = "${color9}"
		green   = "${color10}"
		yellow  = "${color11}"
		blue    = "${color12}"
		magenta = "${color13}"
		cyan    = "${color14}"
		white   = "${color15}"
	_EOF_
}

## Foot --------------------------------------
apply_foot() {
	cat > ${PATH_FOOT}/colors.ini <<- _EOF_
		[colors]
		alpha=1.0
		foreground=${foreground:1}
		background=${background:1}
		regular0=${color0:1}
		regular1=${color1:1}
		regular2=${color2:1}
		regular3=${color3:1}
		regular4=${color4:1}
		regular5=${color5:1}
		regular6=${color6:1}
		regular7=${color7:1}
		bright0=${color8:1}
		bright1=${color9:1}
		bright2=${color10:1}
		bright3=${color11:1}
		bright4=${color12:1}
		bright5=${color13:1}
		bright6=${color14:1}
		bright7=${color15:1}
	_EOF_
}

## Mako --------------------------------------
apply_mako() {
	sed -i '/# Mako_Colors/Q' ${PATH_MAKO}/config
	cat >> ${PATH_MAKO}/config <<- _EOF_
		# Mako_Colors
		background-color=${background}
		text-color=${foreground}
		border-color=${modbackground[1]}
		progress-color=over ${accent}
		[urgency=low]
		border-color=${modbackground[1]}
		default-timeout=2000
		[urgency=normal]
		border-color=${modbackground[1]}
		default-timeout=5000
		[urgency=high]
		border-color=${color1}
		text-color=${color1}
		default-timeout=0
	_EOF_

	pkill mako && bash ${DIR}/scripts/notifications &
}

## Rofi --------------------------------------
apply_rofi() {
	cat > ${PATH_ROFI}/shared/colors.rasi <<- EOF
		* {
		    background:     ${background};
		    background-alt: ${modbackground[1]};
		    foreground:     ${foreground};
		    selected:       ${accent};
		    active:         ${color2};
		    urgent:         ${color1};
		}
	EOF
}

## Waybar ------------------------------------
apply_waybar() {
	cat > ${PATH_WAYB}/colors.css <<- EOF
		@define-color background      ${background};
		@define-color background-alt1 ${modbackground[1]};
		@define-color background-alt2 ${modbackground[2]};
		@define-color foreground      ${foreground};
		@define-color selected        ${accent};
		@define-color black           ${color0};
		@define-color red             ${color1};
		@define-color green           ${color2};
		@define-color yellow          ${color3};
		@define-color blue            ${color4};
		@define-color magenta         ${color5};
		@define-color cyan            ${color6};
		@define-color white           ${color7};
	EOF

	pkill waybar && bash ${DIR}/scripts/statusbar &
}

## Wlogout -----------------------------------
apply_wlogout() {
	cat > ${PATH_WLOG}/colors.css <<- EOF
		@define-color background      ${background};
		@define-color background-alt1 ${modbackground[1]};
		@define-color background-alt2 ${modbackground[2]};
		@define-color foreground      ${foreground};
		@define-color selected        ${accent};
		@define-color black           ${color0};
		@define-color red             ${color1};
		@define-color green           ${color2};
		@define-color yellow          ${color3};
		@define-color blue            ${color4};
		@define-color magenta         ${color5};
		@define-color cyan            ${color6};
		@define-color white           ${color7};
	EOF
}

## Wofi --------------------------------------
apply_wofi() {
	sed -i ${PATH_WOFI}/style.css \
		-e "s/@define-color background .*/@define-color background      ${background};/g" \
		-e "s/@define-color background-alt1 .*/@define-color background-alt1 ${modbackground[1]};/g" \
		-e "s/@define-color background-alt2 .*/@define-color background-alt2 ${modbackground[2]};/g" \
		-e "s/@define-color foreground .*/@define-color foreground      ${foreground};/g" \
		-e "s/@define-color selected .*/@define-color selected        ${accent};/g" \
		-e "s/@define-color black .*/@define-color black           ${color0};/g" \
		-e "s/@define-color red .*/@define-color red             ${color1};/g" \
		-e "s/@define-color green .*/@define-color green           ${color2};/g" \
		-e "s/@define-color yellow .*/@define-color yellow          ${color3};/g" \
		-e "s/@define-color blue .*/@define-color blue            ${color4};/g" \
		-e "s/@define-color magenta .*/@define-color magenta         ${color5};/g" \
		-e "s/@define-color cyan .*/@define-color cyan            ${color6};/g" \
		-e "s/@define-color white .*/@define-color white           ${color7};/g"
}

## Hyprland --------------------------------------
apply_hypr() {
	sed -i ${DIR}/hyprtheme.conf \
		-e "s/\$active_border_col_1 =.*/\$active_border_col_1 = 0xFF${accent:1}/g" \
		-e "s/\$active_border_col_2 =.*/\$active_border_col_2 = 0xFF${color1:1}/g" \
		-e "s/\$inactive_border_col_1 =.*/\$inactive_border_col_1 = 0xFF${modbackground[1]:1}/g" \
		-e "s/\$inactive_border_col_2 =.*/\$inactive_border_col_2 = 0xFF${modbackground[2]:1}/g" \
		-e "s/\$group_border_active_col =.*/\$group_border_active_col = 0xFF${color2:1}/g" \
		-e "s/\$group_border_inactive_col =.*/\$group_border_inactive_col = 0xFF${color3:1}/g" \
		-e "s/\$group_border_locked_active_col =.*/\$group_border_locked_active_col = 0xFF${color1:1}/g" \
		-e "s/\$group_border_locked_inactive_col =.*/\$group_border_locked_inactive_col = 0xFF${color4:1}/g" \
		-e "s/\$groupbar_text_color =.*/\$groupbar_text_color = 0xFF${foreground:1}/g"
}

## The rest is IDENTICAL to your script -----
# Reuse the apply_* functions (Alacritty, Foot, Mako, etc.)
# Paste the same `apply_*` functions from your current script here

## Apply Logic ------------------------------
if [[ "$1" == '--default' ]]; then
	source_default
elif [[ "$1" == '--matugen' ]]; then
	generate_colors_matugen
	cat ${DIR}/theme/colors.bash > ${CURRENT_THEME}
	source ${CURRENT_THEME}
	altbackground="$(pastel color $background | pastel lighten 0.10 | pastel format hex)"
	altforeground="$(pastel color $foreground | pastel darken 0.30 | pastel format hex)"
	modbackground=($(pastel gradient -n 3 $background $altbackground | pastel format hex))
	accent="$color4"
else
	echo "Available Options: --default  --matugen"
	exit 1
fi

## Apply Everything -------------------------
apply_wallpaper
apply_alacritty
apply_foot
apply_mako
apply_rofi
apply_waybar
apply_wlogout
apply_wofi
apply_hypr
