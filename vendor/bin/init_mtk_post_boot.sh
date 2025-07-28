#!/vendor/bin/sh

function configure_memory_info() {
    # Set Zram disk depend on ddrsize (1GB, 2GB, 3GB, 4GB+)
    MemTotalStr=`cat /proc/meminfo`
    MemTotal=${MemTotalStr:16:8}

    configure_lmk_parameters $MemTotal
}

function configure_lmk_parameters() {
    productStr=`getprop ro.product.name`
    product=${productStr:0:3}

    case "$product" in
        # the AMN and KSA(2GB) use the lmk mem 180MB;
        # set 2 in the scan_seek for aggressive kswapd scan.
        "AMN" | "KSA")
            if [ $1 -le 2097152 ]; then
                echo 2 > /sys/module/vmscan/parameters/scan_seek
            else
                echo "18432,23040,27648,32256,55296,80640" > /sys/module/lowmemorykiller/parameters/minfree
            fi
        ;;

        # the default lmk mem is 315MB, the parameters minfree should be "18432,23040,27648,32256,55296,80640",
        # Eg: MRD and JAT use this lmk parameters
        *)
            echo "43776,48384,52992,57600,68096,80640" > /sys/module/lowmemorykiller/parameters/minfree
        ;;
    esac
}

configure_memory_info
