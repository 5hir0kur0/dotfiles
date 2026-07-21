function paru
    env PKGEXT=.pkg.tar paru --sudoloop --newsonupgrade --review \
        --upgrademenu --fm yazi --nouseask --combinedupgrade --provides $argv
    sudo env DIFFPROG='nvim -d' pacdiff
end
