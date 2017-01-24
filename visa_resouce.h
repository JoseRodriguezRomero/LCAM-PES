#ifndef VISA_RESOUCE_H
#define VISA_RESOUCE_H

#include <QString>
#include <visa.h>

class VISA_Resouce
{
private:
    ViSession vi, defaultRM;
    ViStatus status;

    QString vi_rsc_name;

public:
    explicit VISA_Resouce();
    ~VISA_Resouce();

    QString ViResourceName() const;
    void writeData(const QString &data);
    QString readData();

    void setRsrcName(const QString &vi_rsc_name);
    const QString& resourceName() const;

    void openResource();
    void closeResource();
    bool isReachable();
};

#endif // VISA_RESOUCE_H
