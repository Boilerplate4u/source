#! /bin/sh
# A little script I whipped up to make it easy to
# patch source trees and have sane error handling
# -Erik
#
# (c) 2002 Erik Andersen <andersen@codepoet.org>

# Set directories from arguments, or use defaults.
targetdir=${1-.}
patchdir=${2-../kernel-patches}
patchpattern=${3-*}

/usr/bin/printf "\e[48;5;%dm$0:\e[0m %s\n" 244 "$*"


if [ ! -d "${targetdir}" ] ; then
    echo "Aborting.  '${targetdir}' is not a directory."
    exit 1
fi
if [ ! -d "${patchdir}" ] ; then
    echo "Aborting.  '${patchdir}' is not a directory."
    exit 1
fi
    
for i in ${patchdir}/${patchpattern} ; do 
    case "$i" in
	*.gz)
	type="gzip"; uncomp="gunzip -dc"; ;; 
	*.bz)
	type="bzip"; uncomp="bunzip -dc"; ;; 
	*.bz2)
	type="bzip2"; uncomp="bunzip2 -dc"; ;; 
	*.zip)
	type="zip"; uncomp="unzip -d"; ;; 
	*.Z)
	type="compress"; uncomp="uncompress -c"; ;; 
	*)
	type="plaintext"; uncomp="cat"; ;; 
    esac
    [ -d "${i}" ] && echo "Ignoring subdirectory ${i}" && continue	
    echo ""


	# Test if we could reverse the patch and then skip it.
	# if patch --dry-run --reverse --force -i  >/dev/null 2>&1
	if ${uncomp} ${i} | ${PATCH:-patch} --dry-run --reverse --force -p1 -d ${targetdir} >/dev/null 2>&1
	then
  		echo ">>>> Patch already applied (skipping): " $(basename $i)
		echo ">>>> Moving to $patchdir/upstreamed"
		mv $i "$patchdir/upstreamed"
	else # patch not yet applied

		# LAHA
		/usr/bin/printf "Applying \e[48;5;247m${i}\e[0m\n"
		# echo "${uncomp} ${i} | ${PATCH:-patch} -N -p1 -d ${targetdir}"
		# LAHA

		# echo "Applying ${i} using ${type}: " 
		${uncomp} ${i} | ${PATCH:-patch} -N -p1 -d ${targetdir}
		if [ $? != 0 ] ; then
			echo "\n"
			echo "Patch failed:"
			echo "##############################################################"
 			echo "Patch:  $(basename $i)"
			echo "Target: $targetdir"
			echo "##############################################################"
			echo "Moving to $patchdir/failed"
			mv $i "$patchdir/failed"
			echo "\n\n\n"
			# exit 1
		fi
	fi

done

# Check for rejects...
if [ "`find $targetdir/ '(' -name '*.rej' -o -name '.*.rej' ')' -print`" ] ; then
    echo "Aborting.  Reject files found."
    exit 1
fi

# Remove backup files
find $targetdir/ '(' -name '*.orig' -o -name '.*.orig' ')' -exec rm -f {} \;
