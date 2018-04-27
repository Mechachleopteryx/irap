#!/bin/bash

# adds the top level toolbar to all html pages
# makes some extra fixes on the pages
menu=menu.html
# include /
toplevel_path=

if [ ! -e $menu ]; then
    echo "file $menu not found in $PWD"
    exit 2
fi

inject_menu=`cat $menu| tr "\n" " "`

function fix_html_files {
    path=$1

    CSS_FILE='<link rel="stylesheet" href="TTOPLEVELmenu.css">'
    
    # 
    #bash does not have a stack when invoking a function recursively
    if [ "$path-" != "../../../../../../../-" ]; then
	echo $path > .path
	for d in `find -L .  -maxdepth 1  -type d -name  "*"`; do	
	    if [ "$d" != "." ] ; then
		pushd $d > /dev/null
		if [ "$d" != "./data" ]; then
		    echo "Going to dir $d"
		    fix_html_files $path../
		fi
		popd > /dev/null
		path=`cat .path`
		#echo ">>>>>>>>>>>>>>>>>>>>>>>>>>$path $PWD"
	    fi
	done
    fi

    for f in `find . -maxdepth 1 -name  "*.html"`; do
	if [ `basename $f` != $menu ]; then
	    echo "Fixing $f..."
	    # 1st time
	    N=`grep -c "menu.css" $f`
	    if [ "$N-" == "0-" ]; then
		## add CSS FILE
		##echo adding menu.css
  		sed  -E -i "s|<head>|<head>$CSS_FILE|" $f
	    fi
	    # add menu
	    # replace toplevel path
	    # remove r2html
	    # add 
	    N=`grep -c "Just to keep an estimate on the number of people using iRAP" $f`
	    if [ "$N-" == "0-" ]; then
		# add the menu for the first time (first line)
		sed  -E -i "s|(<body[^>]*)>|\1> $inject_menu\n|" $f
	    fi	    
	    sed  -E -i "s|(<body[^>]*)>.*|\1> $inject_menu|;s|TTOPLEVEL|$path|g;s|R2HTML||;s|href=\".*irap.css\"|href=\"${path}irap.css\"|;s|href=\".*menu.css\"|href=\"${path}menu.css\"|" $f
	    #sed  -E -i --file $sed_script $f
	    # remove the line (temporary)
	    #sed -i "s|<p class='character'>Project: <a href='../index.html'>go to main page</a></p>||" $f
	    # keep this temporarily
	    sed -i "s|<object id=\"mathplayer\" .*||" $f
	    echo "'Fixing' $f...done."
	fi    
    done
}
#
fix_html_files

exit 0




