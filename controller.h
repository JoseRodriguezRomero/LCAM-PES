#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <math.h>
#include <stdio.h>

#include <QDir>
#include <QThread>
#include <QObject>
#include <QVector>
#include <QPointF>
#include <QTimer>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include <QtXml/QDomDocument>
#include <QtXml/QDomElement>
#include <QXmlInputSource>
#include <QtXml/QDomAttr>
#include <QXmlReader>

#include "visa_resouce.h"

#ifdef QT_DEBUG
#include <QDebug>
#endif

class Controller : public QObject
{
    Q_OBJECT
private:
    VISA_Resouce counter;
    VISA_Resouce asciipar4;
    VISA_Resouce ion_gauge;

    QTimer step_timer;
    uint current_point;
    uint current_specter;

    uint step_time;                         //in milliseconds
    uint num_specters;

    QString operator_name, specter_name;

    double analyzer_pass_e;                 //in volts
    double channeltron_voltage;             //in volts

    double v_m_field, h_m_field;            //in tesla
    double he_current;                      //in ampere

    double cc_pressure, l_pressure;         //in mBar

    double e_max;                           //maximum energy in eV
    double e_min;                           //minimum energy in eV
    double e_ste;                           //energy step in eV

    QVector<QPointF> new_val, old_val;
    QQmlApplicationEngine *engine;

    QVector<QVector<double>> data;
    QVector<double> pressure;

    QThread thread;
    bool is_running;

public:
    explicit Controller(QObject *parent = 0);
    ~Controller();

    void setEngine(QQmlApplicationEngine *engine);

    Q_INVOKABLE void setCounterName(const QString &rscr_name);
    Q_INVOKABLE void setAsciipar4Name(const QString &rscr_name);
    Q_INVOKABLE void setIongaugeName(const QString &rscr_name);

    Q_INVOKABLE const QString operatorName() const;
    Q_INVOKABLE const QString specterName() const;

    Q_INVOKABLE void setOperatorName(const QString &operator_name);
    Q_INVOKABLE void setSpecterName(const QString &specter_name);

    Q_INVOKABLE double analyzerPassEnergy() const;
    Q_INVOKABLE double channeltronVoltage() const;
    Q_INVOKABLE double heliumCurrent() const;

    Q_INVOKABLE int stepTime() const;
    Q_INVOKABLE int numSpecters() const;

    Q_INVOKABLE void setStepTime(int step_time);
    Q_INVOKABLE void setNumSpecters(int num_specters);

    Q_INVOKABLE void setAnalyzerPassEnergy(double analyzer_pass_e);
    Q_INVOKABLE void setChanneltronVoltage(double channeltron_voltage);
    Q_INVOKABLE void setHeliumCurrent(double he_current);

    Q_INVOKABLE double collisionChamberPressure() const;
    Q_INVOKABLE double lampPressure() const;

    Q_INVOKABLE void setCollisionChamberPressure(double cc_pressure);
    Q_INVOKABLE void setLampPressure(double l_pressure);

    Q_INVOKABLE double upperEnergyBound() const;
    Q_INVOKABLE double lowerEnergyBound() const;
    Q_INVOKABLE double energyStep() const;

    Q_INVOKABLE void setUpperEnergyBound(double e_max);
    Q_INVOKABLE void setLowerEnergyBound(double e_min);
    Q_INVOKABLE void setEnergyStep(double e_ste);

    Q_INVOKABLE double verticalMagneticField() const;
    Q_INVOKABLE double horizontalMagneticField() const;

    Q_INVOKABLE void setVerticalMagneticField(double v_m_field);
    Q_INVOKABLE void setHorizontalMagneticField(double h_m_field);

    Q_INVOKABLE const QString counterResourceName() const;
    Q_INVOKABLE const QString asciipar4ResourceName() const;
    Q_INVOKABLE const QString iongaugeResourceName() const;

    Q_INVOKABLE bool counterIsReachable();
    Q_INVOKABLE bool asciipar4IsReachable();
    Q_INVOKABLE bool iongaugeIsReachable();

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE bool isRunning() const;

    Q_INVOKABLE void save(QString folder_path, QString file_name,
                          QString extension);
    Q_INVOKABLE void setStartInfo();

    void loadBackup();

signals:
    void stepDone();

public slots:
    void onStep();

private:
    void setEnergy();
    void closeCounter();
    void openCounter();

    void readGaugePressure();   // reads from the serial ports the pressure
    void getGaugePressure();    // tells the Arduino to get a new measurement

    void readData();
    void saveBackup();

    void saveTxt(const QString &file_name);
    void saveXml(const QString &file_name);
};

#endif // CONTROLLER_H
