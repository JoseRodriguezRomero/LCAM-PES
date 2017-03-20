#define MAX_BUFFER              32

#include "visa_resouce.h"

VISA_Resouce::VISA_Resouce()
{
}

VISA_Resouce::~VISA_Resouce()
{
    closeResource();
}

QString VISA_Resouce::ViResourceName() const
{
    return vi_rsc_name;
}

void VISA_Resouce::writeData(const QString &data)
{
    openResource();
    ViByte *buffer_data = new ViByte[data.length()];
    ViUInt32 n_to_write,n_written;
    n_to_write = data.length();

    for (uint i = 0; i < n_to_write; i++)
    {
        buffer_data[i] = data.at(i).toLatin1();
    }

    status = viFlush(vi,VI_WRITE_BUF);
    status = viWrite(vi,buffer_data,n_to_write,&n_written);
    closeResource();

    delete[] buffer_data;
}

QString VISA_Resouce::readData()
{
    openResource();
    ViChar buffer[MAX_BUFFER];
    ViPBuf p_buff = (ViByte*)buffer;
    ViUInt32 count;

    viRead(vi,p_buff,MAX_BUFFER-1,&count);
    viFlush(vi,VI_READ_BUF);
    closeResource();

    buffer[count] = '\0';
    return QString(buffer);
}

void VISA_Resouce::setRsrcName(const QString &vi_rsc_name)
{
    this->vi_rsc_name = vi_rsc_name;
}

const QString &VISA_Resouce::resourceName() const
{
    return vi_rsc_name;
}

void VISA_Resouce::openResource()
{
    char *vi_name = new char[vi_rsc_name.length()];
    strcpy(vi_name,vi_rsc_name.toStdString().data());

    status = viOpenDefaultRM(&defaultRM);
    status = viOpen(defaultRM,vi_name,VI_NULL,VI_NULL,&vi);

    delete[] vi_name;
}

void VISA_Resouce::closeResource()
{
    viClose(vi);
    viClose(defaultRM);
}

bool VISA_Resouce::isReachable()
{
    openResource();
    bool ret = (status == VI_SUCCESS);
    closeResource();

    return ret;
}
