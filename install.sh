#!/bin/sh

export $(xargs <.env)
# while read -r line; do
#     export "$line"
# done <.env

getOption() {
    return $((promethues_option & grafana_option & node_option))
}

# option
promethues_option=$((1 << 0))
grafana_option=$((1 << 1))
node_option=$((1 << 2))

defalut_option=getOption

# path
base_path=$(pwd)

prometheus_path="${base_path}/prometheus"
grafana_path="${base_path}/grafana"
node_path="${base_path}/exporters/node"

resource_path="${base_path}/resources"
log_path="${base_path}/log"

# pkg name
prometheus_pkg_name="prometheus-${STRAY_CAT_PROMETHEUS_VERSION}.linux-amd64.tar.gz"
grafana_pkg_name="grafana-${STRAY_CAT_GRAFANA_VERSION}.linux-amd64.tar.gz"
node_pkg_name="node_exporter-${STRAY_CAT_EXPORTER_NODE_VERSION}.linux-amd64.tar.gz"

# pkg unpack name
prometheus_unpack_name="prometheus-${STRAY_CAT_PROMETHEUS_VERSION}.linux-amd64"
grafana_unpack_name="grafana-${STRAY_CAT_GRAFANA_VERSION}"
node_unpack_name="node_exporter-${STRAY_CAT_EXPORTER_NODE_VERSION}.linux-amd64"

# pkg resource dir name
prometheus_resource_dir_name="$resource_path/$prometheus_unpack_name"
grafana_resource_dir_name="$resource_path/$grafana_unpack_name"
node_resource_dir_name="$resource_path/$node_unpack_name"

# download path
prometheus_dl_path=https://github.com/prometheus/prometheus/releases/download/v${STRAY_CAT_PROMETHEUS_VERSION}/${prometheus_pkg_name}
grafana_dl_path=https://dl.grafana.com/oss/release/${grafana_pkg_name}
node_dl_path=https://github.com/prometheus/node_exporter/releases/download/v${STRAY_CAT_EXPORTER_NODE_VERSION}/${node_pkg_name}

# bin path
prometheus_bin_path="$prometheus_path"
grafana_bin_path="$grafana_path/bin"
node_bin_path="$node_path"

# bin file
prometheus_bin_file="$prometheus_bin_path/prometheus"
grafana_bin_file="$grafana_bin_path/grafana-server"
node_bin_file="$node_bin_path/node_exporter"

# file name
prometheus_file_name="$resource_path/$prometheus_pkg_name"
grafana_file_name="$resource_path/$grafana_pkg_name"
node_file_name="$resource_path/$node_pkg_name"

# config file path
prometheus_config_path="${base_path}/$STRAY_CAT_PROMETHEUS_CONFIG"

initEnv() {
    getOption() {
        return $((promethues_option & grafana_option & node_option))
    }

    # option
    promethues_option=$((1 << 0))
    grafana_option=$((1 << 1))
    node_option=$((1 << 2))

    defalut_option=getOption

    # path
    base_path=$(pwd)

    prometheus_path="${base_path}/prometheus"
    grafana_path="${base_path}/grafana"
    node_path="${base_path}/exporters/node"

    resource_path="${base_path}/resources"
    log_path="${base_path}/log"

    # pkg name
    prometheus_pkg_name="prometheus-${STRAY_CAT_PROMETHEUS_VERSION}.linux-amd64.tar.gz"
    grafana_pkg_name="grafana-${STRAY_CAT_GRAFANA_VERSION}.linux-amd64.tar.gz"
    node_pkg_name="node_exporter-${STRAY_CAT_EXPORTER_NODE_VERSION}.linux-amd64.tar.gz"

    # pkg unpack name
    prometheus_unpack_name="prometheus-${STRAY_CAT_PROMETHEUS_VERSION}.linux-amd64"
    grafana_unpack_name="grafana-${STRAY_CAT_GRAFANA_VERSION}"
    node_unpack_name="node_exporter-${STRAY_CAT_EXPORTER_NODE_VERSION}.linux-amd64"

    # pkg resource dir name
    prometheus_resource_dir_name="$resource_path/$prometheus_unpack_name"
    grafana_resource_dir_name="$resource_path/$grafana_unpack_name"
    node_resource_dir_name="$resource_path/$node_unpack_name"

    # download path
    prometheus_dl_path=https://github.com/prometheus/prometheus/releases/download/v${STRAY_CAT_PROMETHEUS_VERSION}/${prometheus_pkg_name}
    grafana_dl_path=https://dl.grafana.com/oss/release/${grafana_pkg_name}
    node_dl_path=https://github.com/prometheus/node_exporter/releases/download/v${STRAY_CAT_EXPORTER_NODE_VERSION}/${node_pkg_name}

    # bin path
    prometheus_bin_path="$prometheus_path"
    grafana_bin_path="$grafana_path/bin"
    node_bin_path="$node_path"

    # bin file
    prometheus_bin_file="$prometheus_bin_path/prometheus"
    grafana_bin_file="$grafana_bin_path/grafana-server"
    node_bin_file="$node_bin_path/node_exporter"

    # file name
    prometheus_file_name="$resource_path/$prometheus_pkg_name"
    grafana_file_name="$resource_path/$grafana_pkg_name"
    node_file_name="$resource_path/$node_pkg_name"

    # config file path
    prometheus_config_path="${base_path}/$STRAY_CAT_PROMETHEUS_CONFIG"
}

#######################custom function###########################
installPrometheus() {
    echo "$prometheus_file_name will install"
    if [ ! -f "$prometheus_file_name" ]; then
        downloadPrometheus
    else
        echo "$prometheus_file_name is exits"
    fi

    tar -zxvf "$prometheus_file_name" -C "$resource_path" >/dev/null

    ln -s "$prometheus_resource_dir_name" "$prometheus_path"
}

downloadPrometheus() {
    echo "download $prometheus_file_name"

    wget -O "$prometheus_file_name" "$prometheus_dl_path"
    # curl -s -o "$prometheus_file_name" "$prometheus_dl_path"
}

prometheus_pid=1

runPrometheus() {
    echo "run prometheus ${prometheus_bin_file}"
    prometheus_pid=$(
        nohup "${prometheus_bin_file}" --config.file="$prometheus_config_path" >"${log_path}/prometheus.log" 2>&1 &
        echo $!
    )
    echo "run prometheus $prometheus_pid"
}

installGrafana() {
    echo "$grafana_file_name will install"
    if [ ! -f "$grafana_file_name" ]; then
        downloadGrafana
    else
        echo "$grafana_file_name is exits"
    fi

    tar -zxvf "$grafana_file_name" -C "$resource_path" >/dev/null

    ln -s "$grafana_resource_dir_name" "$grafana_path"
}

downloadGrafana() {
    echo "download $grafana_file_name"

    wget -O "$grafana_file_name" "$grafana_dl_path"
    # curl -s -o "$grafana_file_name" "$grafana_dl_path"
}

grafana_pid=1

runGrafana() {
    echo "run grafana ${grafana_bin_file}"
    grafana_pid=$(
        nohup "${grafana_bin_file}" --homepath="$grafana_path" >"${log_path}/grafana.log" 2>&1 &
        echo $!
    )
    echo "run grafana $grafana_pid"
}

installNode() {
    echo "$node_file_name will install"
    if [ ! -f "$node_file_name" ]; then
        downloaNode
    else
        echo "$node_file_name is exits"
    fi

    tar -zxvf "$node_file_name" -C "$resource_path" >/dev/null

    ln -s "$node_resource_dir_name" "$node_path"
}

downloaNode() {
    echo "download $node_file_name"

    wget -O "$node_file_name" "$node_dl_path"
    # curl -s -o "$node_file_name" "$node_dl_path"
}

node_pid=1

runNode() {
    echo "run node ${node_bin_file}"
    node_pid=$(
        nohup "${node_bin_file}" >"${log_path}/node.log" 2>&1 &
        echo $!
    )
    echo "run node $node_pid"
}

pidIsRunning() {
    if ps -p "$1" >/dev/null; then
        echo "$1 is running"
    # Do something knowing the pid exists, i.e. the process with $1 is running
    else
        echo "$1 is not running. please check log"
    fi
}

killProcess() {
    for pid in $(pgrep "$1"); do
        kill -15 "$pid"
        echo "$1 pid $pid is killed"
    done
}

cleanEnv() {
    killProcess "prometheus"
    killProcess "grafana"
    killProcess "node_exporter"

    echo "check $prometheus_path"
    if [ -d "$prometheus_path" ]; then
        rm -rf "$prometheus_path"
        echo "rm $prometheus_path"
    fi

    echo "check $grafana_path"
    if [ -d "$grafana_path" ]; then
        rm -rf "$grafana_path"
        echo "rm $grafana_path"
    fi

    echo "check $node_path"
    if [ -d "$node_path" ]; then
        rm -rf "$node_path"
        echo "rm $node_path"
    fi

    echo "check resource $prometheus_resource_dir_name"
    if [ -d "$prometheus_resource_dir_name" ]; then
        echo "rm resource $prometheus_resource_dir_name"
        rm -rf "$prometheus_resource_dir_name"
    fi

    echo "check resource $grafana_resource_dir_name"
    if [ -d "$grafana_resource_dir_name" ]; then
        echo "rm resource $grafana_resource_dir_name"
        rm -rf "$grafana_resource_dir_name"
    fi

    echo "check resource $node_resource_dir_name"
    if [ -d "$node_resource_dir_name" ]; then
        echo "rm resource $node_resource_dir_name"
        rm -rf "$node_resource_dir_name"
    fi

    unset promethues_option
    unset grafana_option
    unset node_option
    unset defalut_option
    unset base_path
    unset prometheus_path
    unset grafana_path
    unset node_path
    unset resource_path
    unset log_path
    unset prometheus_pkg_name
    unset grafana_pkg_name
    unset node_pkg_name
    unset prometheus_unpack_name
    unset grafana_unpack_name
    unset node_unpack_name
    unset prometheus_resource_dir_name
    unset grafana_resource_dir_name
    unset node_resource_dir_name
    unset prometheus_dl_path
    unset grafana_dl_path
    unset node_dl_path
    unset prometheus_bin_path
    unset grafana_bin_path
    unset node_bin_path
    unset prometheus_bin_file
    unset grafana_bin_file
    unset node_bin_file
    unset prometheus_file_name
    unset grafana_file_name
    unset node_file_name
    unset prometheus_config_path
}

checkPid() {
    sleep 3

    echo "check prometheus"
    pidIsRunning "$prometheus_pid"
    echo "check grafana"
    pidIsRunning "$grafana_pid"
    echo "check node_exporter"
    pidIsRunning "$node_pid"
}

######################end##########################
# pre run
cleanEnv
initEnv

# run
installGrafana
installPrometheus
installNode

runPrometheus
runGrafana
runNode

checkPid
