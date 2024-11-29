sudo swapoff -a
cd ~/oaic/oaic/RIC-Deployment/tools/k8s/bin
./gen-cloud-init.sh
sudo ./k8s-1node-cloud-init-k_1_16-h_2_17-d_cur.sh
sudo kubectl create ns ricinfra
sudo helm install stable/nfs-server-provisioner --namespace ricinfra --name nfs-release-1
sudo kubectl patch storageclass nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo apt install nfs-common -y
sudo docker run -d -p 5001:5000 --restart=always --name ric registry:2
sudo docker pull oaic/e2:5.5.0
sudo docker tag oaic/e2:5.5.0 localhost:5001/ric-plt-e2:5.5.0
sudo docker push localhost:5001/ric-plt-e2:5.5.0
cd ~/oaic/oaic/RIC-Deployment/bin
sudo ./deploy-ric-platform -f ../RECIPE_EXAMPLE/PLATFORM/example_recipe_oran_e_release_modified_e2.yaml
cd ~/oaic/oaic/asn1c
git checkout velichkov_s1ap_plus_option_group
autoreconf -iv
./configure
make -j`nproc`
sudo make install
sudo ldconfig
cd ~/oaic
cd srslte-e2
export SRS=`realpath .`
cd build
cmake ../ -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DRIC_GENERATED_E2AP_BINDING_DIR=${SRS}/e2_bindings/E2AP-v01.01 \
    -DRIC_GENERATED_E2SM_KPM_BINDING_DIR=${SRS}/e2_bindings/E2SM-KPM \
    -DRIC_GENERATED_E2SM_GNB_NRT_BINDING_DIR=${SRS}/e2_bindings/E2SM-GNB-NRT
make -j`nproc`
sudo make install
sudo ldconfig
y || sudo srslte_install_configs.sh user --force
