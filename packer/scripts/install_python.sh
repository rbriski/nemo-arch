curl https://pyenv.run | bash

echo 'export PATH="$HOME/.pyenv/bin:/usr/local/cuda-11.7/bin:$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH"' >> $HOME/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc
echo 'eval "$(pyenv init -)' >> $HOME/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc

export PATH="$HOME/.pyenv/bin:/usr/local/cuda-11.7/bin:$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo $PATH

sleep 10
pyenv install 3.10.9
pyenv global 3.10.9

sleep 10
pip install nvtx
pip install torch torchvision
pip install packaging
pip install ninja

git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" --global-option="--fast_layer_norm" --global-option="--distributed_adam" --global-option="--deprecated_fused_adam" ./

pip install Cython
pip install git+https://github.com/NVIDIA/NeMo.git$BRANCH#egg=nemo_toolkit[nlp]