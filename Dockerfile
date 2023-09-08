FROM ubuntu:18.04

## Install base utilities
## cv2 needs ffmpeg libsm6 libxext6
# RUN apt update & apt install -y build-essential wget ghostscript ffmpeg libsm6 libxext6 
RUN apt-get -y update && apt-get install -y --no-install-recommends wget ghostscript ffmpeg libsm6 libxext6 gnupg gnupg2 gnupg1 unzip gsfonts-x11
#& \
# apt-get clean & \
# rm -rf /var/lib/apt/lists/*

# # Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && chmod 777 ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
# --quiet
# # Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH
COPY environment.yml environment.yml
RUN /bin/bash -c "source ~/.bashrc && conda init bash && \
    conda env create -f environment.yml" \
    && wget -q -O - --no-check-certificate https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add \
    && echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get -y update && apt-get -y --no-install-recommends install google-chrome-stable \
    && chmod +x usr/bin/google-chrome \
    && chmod +x usr/bin/google-chrome-stable \
    && wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/116.0.5845.96/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip \
    && mv chromedriver-linux64 /usr/bin/chromedriver-linux64 \
    && chown root:root /usr/bin/chromedriver-linux64 \
    && chmod +x /usr/bin/chromedriver-linux64 \
    && rm chromedriver-linux64.zip \
    && wget --no-check-certificate https://dl.xpdfreader.com/xpdf-tools-linux-4.04.tar.gz \
    && tar -zxvf xpdf-tools-linux-4.04.tar.gz \
    && rm xpdf-tools-linux-4.04.tar.gz \
    && cp xpdf-tools-linux-4.04/bin64/pdftohtml /usr/local/bin \
    && rm -r xpdf-tools-linux-4.04


# ---------
# chromedriver
# needs gnupg gnupg2 gnupg1 for installation
# ---------
# ---------
# xpdf tools. Note: apt install xpdf does not work (maybe it's bin32?), stick
# to the provided TAR.
# needs gsfonts-x11
# docker build -t pdfigcapx:0.1 .
# opencv
# RUN /bin/bash -c "source ~/.bashrc && conda init bash && \
# conda install -c anaconda numpy pillow pytest --yes && \
# conda install -c conda-forge matplotlib selenium  --yes" \
# ---------

# missing yapf