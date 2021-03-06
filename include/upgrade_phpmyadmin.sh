#upgrade phpmyadmin
upgrade_phpmyadmin(){

    if [ -d ${web_root_dir}/phpmyadmin ]; then
        installed_pma=`awk '/Version/{print $2}' ${web_root_dir}/phpmyadmin/README`
    else
        if [ -s "$cur_dir/pmaversion.txt" ]; then
            installed_pma=`awk '/phpmyadmin/{print $2}' ${cur_dir}/pmaversion.txt`
        else
            echo -e "phpmyadmin\t0" > ${cur_dir}/pmaversion.txt
            installed_pma=`awk '/phpmyadmin/{print $2}' ${cur_dir}/pmaversion.txt`
        fi
    fi

    latest_pma=`curl -s https://www.phpmyadmin.net/files/ | awk -F\> '/\/files\//{print $3}' | grep '4.4' | cut -d'<' -f1 | sort -V | tail -1`
    if [ -z ${latest_pma} ]; then
        latest_pma=`curl -s http://lamp.teddysun.com/pmalist.txt | grep '4.4' | tail -1 | awk -F- '{print $2}'`
    fi
    echo -e "Latest version of phpmyadmin: \033[41;37m ${latest_pma} \033[0m"
    echo -e "Installed version of phpmyadmin: \033[41;37m $installed_pma \033[0m"
    echo ""
    echo "Do you want to upgrade phpmyadmin ? (y/n)"
    read -p "(Default: n):" upgrade_pma
    if [ -z ${upgrade_pma} ]; then
        upgrade_pma="n"
    fi
    echo "---------------------------"
    echo "You choose = ${upgrade_pma}"
    echo "---------------------------"
    echo ""
    get_char() {
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`

    if [[ "${upgrade_pma}" = "y" || "${upgrade_pma}" = "Y" ]];then
        echo "phpMyAdmin upgrade start..."

        if [ -d ${web_root_dir}/phpmyadmin ]; then
            mv ${web_root_dir}/phpmyadmin/config.inc.php ${cur_dir}/config.inc.php
            rm -rf ${web_root_dir}/phpmyadmin
        else
            echo "phpMyAdmin folder not found..."
        fi

        if [ ! -d ${cur_dir}/software ];then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ ! -s phpMyAdmin-${latest_pma}-all-languages.tar.gz ]; then
            latest_pma_link="http://files.phpmyadmin.net/phpMyAdmin/${latest_pma}/phpMyAdmin-${latest_pma}-all-languages.tar.gz"
            backup_pma_link="http://lamp.teddysun.com/files/phpMyAdmin-${latest_pma}-all-languages.tar.gz"
            untar ${latest_pma_link} ${backup_pma_link}
            mkdir -p ${web_root_dir}/phpmyadmin
            mv * ${web_root_dir}/phpmyadmin
        else
            tar -zxf phpMyAdmin-${latest_pma}-all-languages.tar.gz
            mv phpMyAdmin-${latest_pma}-all-languages ${web_root_dir}/phpmyadmin
        fi
        if [ -s ${cur_dir}/config.inc.php ]; then
            mv ${cur_dir}/config.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
        else
            mv ${web_root_dir}/phpmyadmin/config.sample.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
        fi
        mkdir -p ${web_root_dir}/phpmyadmin/{upload,save}
        if [ -s ${web_root_dir}/phpmyadmin/examples/create_tables.sql ]; then
            cp -f ${web_root_dir}/phpmyadmin/examples/create_tables.sql ${web_root_dir}/phpmyadmin/upload/
        elif [ -s ${web_root_dir}/phpmyadmin/sql/create_tables.sql ]; then
            cp -f ${web_root_dir}/phpmyadmin/sql/create_tables.sql ${web_root_dir}/phpmyadmin/upload/
        fi

        chown -R apache:apache ${web_root_dir}/phpmyadmin

        echo -e "phpmyadmin\t${latest_pma}" > ${cur_dir}/pmaversion.txt

        echo "Clear up start..."
        cd ${cur_dir}/software
        rm -rf phpMyAdmin-${latest_pma}-all-languages/
        rm -f phpMyAdmin-${latest_pma}-all-languages.tar.gz
        echo "Clear up completed..."

        echo "phpMyAdmin upgrade completed..."
    else
        echo
        echo "phpMyAdmin upgrade cancelled, nothing to do..."
        echo
    fi

}
