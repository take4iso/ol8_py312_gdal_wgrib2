FROM oraclelinux:8


RUN dnf config-manager --enable ol8_codeready_builder && \
    dnf update && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf -y install langpacks-ja glibc-langpack-ja.x86_64 wget gcc gcc-c++ make cmake git m4 libcurl-devel python312 python3.12-devel python3.12-pip unzip libdap zlib-devel proj proj-devel swig

RUN alternatives --set python3 /usr/bin/python3.12
RUN pip3 install --upgrade pip && \
    pip3 install setuptools numpy

# sqlite3のインストール
RUN cd /root && \
    wget https://sqlite.org/2025/sqlite-autoconf-3490100.tar.gz && \
    tar -zxvf sqlite-autoconf-3490100.tar.gz && \
    cd sqlite-autoconf-3490100 && \
    ./configure --prefix=/usr --enable-all && \
    CFLAGS="-DHAVE_READLINE=1 -DSQLITE_ALLOW_URI_AUTHORITY=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_DBPAGE_VTAB=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_ENABLE_DESERIALIZE=1 -DSQLITE_ENABLE_FTS4=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_ENABLE_GEOPOLY=1 -DSQLITE_ENABLE_JSON1=1 -DSQLITE_ENABLE_MEMSYS3=1 -DSQLITE_ENABLE_PREUPDATE_HOOK=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_SESSION=1 -DSQLITE_ENABLE_SNAPSHOT=1 -DSQLITE_ENABLE_STMTVTAB=1 -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_INTROSPECTION_PRAGMAS=1 -DSQLITE_USE_ALLOCA=1 -DSQLITE_USE_FCNTL_TRACE=1 -DSQLITE_HAVE_ZLIB=1" && \ 
    make && \
    make install

# hdf5のインストール（バージョン注意：1.14.6だとnetcdfのビルドでエラーが出る）
RUN cd /root && \
    wget https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.5/hdf5.tar.gz && \
    tar -zxvf hdf5.tar.gz && \
    cd hdf5-1.14.5 && \
    mkdir build && \
    cd build && \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_SHARED_LIBS:BOOL=ON -DBUILD_TESTING:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DCMAKE_INSTALL_PREFIX=/usr -DHDF5_BUILD_CPP_LIB:BOOL=ON ../ && \
    make && \
    #ctest . -C Release && \
    make install

# netcdfのインストール
RUN cd /root && \
    git clone https://github.com/Unidata/netcdf-c.git -b v4.9.3 --depth 1 && \
    cd netcdf-c && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr -DNETCDF_ENABLE_HDF5=ON ../ && \
    make && \
    #ctest && \
    make install

# wgrib2のインストール
RUN cd /root && \
    git clone https://github.com/NOAA-EMC/wgrib2 && \
    cd wgrib2 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr/lib -DUSE_NETCDF=ON ../ && \
    make && \
    make install

# gdalのインストール
RUN cd /root && \
    git clone https://github.com/OSGeo/gdal && \
    cd gdal && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_PYTHON_BINDINGS:BOOL=ON .. && \
    cmake --build . && \
    cmake --build . --target install


# あとかたづけ
RUN rm -rf /root/*
