FROM alpine:3.6

ENV TESSDATA https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata
ENV OPENCV https://github.com/opencv/opencv/archive/3.3.0.tar.gz
ENV OPENCV_VER 3.3.0
ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

RUN apk update && apk add git 
RUN mkdir -p /usr/inst_script && cd /usr/inst_script && git clone https://github.com/Howki/inst_proc_image .
RUN cd /usr/inst_script && chmod +x insta.py
RUN ln -s -f /usr/inst_script/insta.py /usr/bin/insta

RUN apk add -U --no-cache --virtual=build-dependencies \
    linux-headers musl libxml2-dev libxslt-dev libffi-dev g++ \
    musl-dev libgcc openssl-dev jpeg-dev zlib-dev freetype-dev build-base \
    lcms2-dev openjpeg-dev python3-dev make cmake clang clang-dev ninja \

    && apk add --no-cache gcc tesseract-ocr zlib jpeg libjpeg freetype openjpeg curl python3 \
    && curl https://bootstrap.pypa.io/get-pip.py | python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && curl $TESSDATA -o /usr/share/tessdata/eng.traineddata \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \
    && pip install -U --no-cache-dir Pillow pytesseract numpy

RUN mkdir -p /opt && cd /opt && \
    curl -L $OPENCV | tar zx && \
    cd opencv-$OPENCV_VER && \
    mkdir build && cd build && \
    cmake -G Ninja \
          -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_FFMPEG=NO \
          -D WITH_IPP=NO \
          -D PYTHON_EXECUTABLE=/usr/bin/python \
          -D WITH_OPENEXR=NO .. && \
    ninja && ninja install && \
    ln -s /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so \
          /usr/lib/python3.6/site-packages/cv2.so && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*
