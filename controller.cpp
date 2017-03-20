#define MAX_BUFFER                      32

#define DEFAULT_OPERATOR_NAME           "Bob the builder"
#define DEFAULT_SPECTER_NAME            "Kryptonite"

#define DEFAULT_COUNTER_RSRC_NAME       "counter"
#define DEFAULT_ASCIIPAR4_RSRC_NAME     "asciipar4"
#define DEFAULT_IONGAUGE_RSRC_NAME      "iongauge"

#define DEFAULT_UPPER_BOUND             1.0
#define DEFAULT_LOWER_BOUND             0.0
#define DEFAULT_STEP                    1E-2

#define DEFAULT_STEP_TIME               100
#define DEFAULT_SWIPES                  10

#define DEFAULT_COL_CHAMBER_PRESSURE    5E-9
#define DEFAULT_LAMP_PRESSURE           5E-9

#define DEFAULT_H_FIELD                 0.0
#define DEFAULT_V_FIELD                 0.0

#define DEFAULT_ANALIZER_PASS_E         0.0
#define DEFAULT_HE_CURRENT              0.0
#define DEFAULT_CHANNELTRON_V           0.0

#include "controller.h"

Controller::Controller(QObject *parent) :
    QObject(parent)
{
    current_point = 0;
    current_specter = 0;

    counter.setRsrcName(DEFAULT_COUNTER_RSRC_NAME);
    asciipar4.setRsrcName(DEFAULT_ASCIIPAR4_RSRC_NAME);
    ion_gauge.setRsrcName(DEFAULT_IONGAUGE_RSRC_NAME);

    operator_name = DEFAULT_OPERATOR_NAME;
    specter_name = DEFAULT_SPECTER_NAME;

    analyzer_pass_e = DEFAULT_ANALIZER_PASS_E;
    channeltron_voltage = DEFAULT_CHANNELTRON_V;
    he_current = DEFAULT_HE_CURRENT;

    cc_pressure = DEFAULT_COL_CHAMBER_PRESSURE;
    l_pressure = DEFAULT_LAMP_PRESSURE;

    step_time = DEFAULT_STEP_TIME;
    num_specters = DEFAULT_SWIPES;

    current_point = 0;
    current_specter = 1;

    e_max = DEFAULT_UPPER_BOUND;
    e_min = DEFAULT_LOWER_BOUND;
    e_ste = DEFAULT_STEP;

    h_m_field = DEFAULT_H_FIELD;
    v_m_field = DEFAULT_V_FIELD;

    is_running = false;

    this->moveToThread(&thread);
    thread.start();

    step_timer.setSingleShot(true);
    connect(&step_timer,SIGNAL(timeout()),this,SLOT(onStep()));
    connect(this,SIGNAL(stepDone()),&step_timer,SLOT(start()));
}

Controller::~Controller()
{
    current_point = 0;
    closeCounter();
    setEnergy();

    is_running = false;
    while (thread.isRunning())
    {
        thread.quit();
    }
}

void Controller::setEngine(QQmlApplicationEngine *engine)
{
    this->engine = engine;

    current_point = 0;
    closeCounter();
    setEnergy();
}

void Controller::setCounterName(const QString &rscr_name)
{
    counter.setRsrcName(rscr_name);
}

void Controller::setAsciipar4Name(const QString &rscr_name)
{
    asciipar4.setRsrcName(rscr_name);
}

void Controller::setIongaugeName(const QString &rscr_name)
{
    ion_gauge.setRsrcName(rscr_name);
}

const QString Controller::operatorName() const
{
    return operator_name;
}

const QString Controller::specterName() const
{
    return specter_name;
}

void Controller::setOperatorName(const QString &operator_name)
{
    this->operator_name = operator_name;
}

void Controller::setSpecterName(const QString &specter_name)
{
    this->specter_name = specter_name;
}

double Controller::analyzerPassEnergy() const
{
    return analyzer_pass_e;
}

double Controller::channeltronVoltage() const
{
    return channeltron_voltage;
}

double Controller::heliumCurrent() const
{
    return he_current;
}

int Controller::stepTime() const
{
    return step_time;
}

int Controller::numSpecters() const
{
    return num_specters;
}

void Controller::setStepTime(int step_time)
{
    this->step_time = step_time;
}

void Controller::setNumSpecters(int num_specters)
{
    this->num_specters = num_specters;
}

void Controller::setAnalyzerPassEnergy(double analyzer_pass_e)
{
    this->analyzer_pass_e = analyzer_pass_e;
}

void Controller::setChanneltronVoltage(double channeltron_voltage)
{
    this->channeltron_voltage = channeltron_voltage;
}

void Controller::setHeliumCurrent(double he_current)
{
    this->he_current = he_current;
}

double Controller::collisionChamberPressure() const
{
    return cc_pressure;
}

double Controller::lampPressure() const
{
    return l_pressure;
}

void Controller::setCollisionChamberPressure(double cc_pressure)
{
    this->cc_pressure = cc_pressure;
}

void Controller::setLampPressure(double l_pressure)
{
    this->l_pressure = l_pressure;
}

double Controller::upperEnergyBound() const
{
    return e_max;
}

double Controller::lowerEnergyBound() const
{
    return e_min;
}

double Controller::energyStep() const
{
    return e_ste;
}

void Controller::setUpperEnergyBound(double e_max)
{
    this->e_max = e_max;
}

void Controller::setLowerEnergyBound(double e_min)
{
    this->e_min = e_min;
}

void Controller::setEnergyStep(double e_ste)
{
    this->e_ste = e_ste;
}

double Controller::verticalMagneticField() const
{
    return v_m_field;
}

double Controller::horizontalMagneticField() const
{
    return h_m_field;
}

void Controller::setVerticalMagneticField(double v_m_field)
{
    this->v_m_field = v_m_field;
}

void Controller::setHorizontalMagneticField(double h_m_field)
{
    this->h_m_field = h_m_field;
}

const QString Controller::counterResourceName() const
{
    return counter.resourceName();
}

const QString Controller::asciipar4ResourceName() const
{
    return asciipar4.resourceName();
}

const QString Controller::iongaugeResourceName() const
{
    return ion_gauge.resourceName();
}

bool Controller::counterIsReachable()
{
    return counter.isReachable();
}

bool Controller::asciipar4IsReachable()
{
    return asciipar4.isReachable();
}

bool Controller::iongaugeIsReachable()
{
    return ion_gauge.isReachable();
}

void Controller::start()
{
    setStartInfo();
    current_specter = 1;
    current_point = 0;

    data.clear();
    old_val.clear();
    new_val.clear();
    data.clear();

    uint n_points = round((e_max-e_min)/e_ste) + 1;
    data.resize(num_specters);

    QObject *object = engine->rootObjects().first();
    QMetaObject::invokeMethod(object,"set_specter_axisY_max",
                              Q_ARG(QVariant,10));
    QMetaObject::invokeMethod(object,"set_specter_axisY_min",
                              Q_ARG(QVariant,0));
    QMetaObject::invokeMethod(object,"set_specter_axisX_max",
                              Q_ARG(QVariant,e_max));
    QMetaObject::invokeMethod(object,"set_specter_axisX_min",
                              Q_ARG(QVariant,e_min));

    QMetaObject::invokeMethod(object,"has_started");
    QMetaObject::invokeMethod(object,"set_specter_points",
                              Q_ARG(QVariant,n_points));

    for (uint i = 0; i < n_points; i++)
    {
        double x_val = e_min + e_ste*i;
        old_val.append(QPointF(x_val,0.0));
        new_val.append(QPointF(x_val,0.0));
    }

    step_timer.setInterval(step_time);

    is_running = true;

    setEnergy();
    openCounter();
    emit stepDone();
}

void Controller::stop()
{
    is_running = false;
}

bool Controller::isRunning() const
{
    return is_running;
}

void Controller::save(QString folder_path, QString file_name,
                      QString extension)
{
    folder_path.remove(0,8);
    file_name.remove(0,8);
    file_name.remove(0,folder_path.length()+1);
    QDir::setCurrent(folder_path);

    if (extension == ".txt")
    {
        saveTxt(file_name);
    }
    else
    {
        saveXml(file_name);
    }
}

void Controller::setStartInfo()
{
    QObject *object = engine->rootObjects().first();
    QMetaObject::invokeMethod(object,"set_energy_step",
                              Q_ARG(QVariant,e_ste));
    QMetaObject::invokeMethod(object,"set_specter_num",
                              Q_ARG(QVariant,current_specter),
                              Q_ARG(QVariant,num_specters));
    QMetaObject::invokeMethod(object,"set_time_per_step",
                              Q_ARG(QVariant,step_time));

    uint n_points = round((e_max-e_min)/e_ste) + 1;
    double elapsed_time = (n_points - current_point)*step_time;
    elapsed_time += (num_specters-current_specter)*(n_points*step_time);
    elapsed_time /= 1000;

    QMetaObject::invokeMethod(object,"set_elapsed_time",
                              Q_ARG(QVariant,elapsed_time));
}

void Controller::onStep()
{
    if (!is_running)
    {
        closeCounter();
        setEnergy();
        QObject *object = engine->rootObjects().first();
        QMetaObject::invokeMethod(object,"has_stopped");
        return;
    }

    closeCounter();
    readData();

    uint n_points = round((e_max-e_min)/e_ste) + 1;

    current_point++;
    if (current_point >= n_points)
    {
        if (current_specter >= num_specters)
        {
            is_running = false;
        }
        else
        {
            current_point = 0;
            current_specter++;
        }

        saveBackup();
    }

    setStartInfo();
    setEnergy();
    openCounter();

    emit stepDone();
}

void Controller::setEnergy()
{
    double a = float((2<<17)-1) / 9.9999;    //resolution of the DAC
    double z1 = (e_min+(current_point*e_ste))*a;
    char d = '0';

    if (!is_running)
    {
        z1 = 0;
    }

    char buffer[MAX_BUFFER];
    buffer[16] = '\n';
    for (int i = 0; i < 16; i++)
    {
        z1 = floor(z1);
        char r = z1-floor(z1/8.0)*8+d;
        z1 = floor(z1/8.0);

        buffer[15-i] = r;
    }

    asciipar4.writeData((char*)buffer);
}

void Controller::closeCounter()
{
    ViByte buffer[MAX_BUFFER] = {'F','N','6','\n','\r'};
    counter.writeData((ViChar*)buffer);
}

void Controller::openCounter()
{
    ViByte buffer[MAX_BUFFER] = {'R','E','F','N','1','2','\n','\r'};
    counter.writeData((ViChar*)buffer);
}

void Controller::readGaugePressure()
{
    QString data = ion_gauge.readData();
    while (data[data.length()-1] != '\n')
    {
        getGaugePressure();
        data = ion_gauge.readData();
    }

    int v = data.toInt();
    double p = (3.81E-7)*pow(v,3)-(1.5E-4)*pow(v,3)+(2.52E-2)*v-2.6;
    p = pow(10.0,p);

    int n = ((e_max - e_min) / e_ste) + 1;
    double t = (current_specter*n + current_point)*step_time*1.0E-3;

    pressure.append(p);

    QObject *object = engine->rootObjects().first();
    QMetaObject::invokeMethod(object,"add_pressure_point",
                              Q_ARG(QVariant,t),
                              Q_ARG(QVariant,p));
}

void Controller::getGaugePressure()
{

}

void Controller::readData()
{
    QString data = counter.readData();
    while ((data.length() > 0) &&
           (data[0] < '0' || data[0] > '9'))
    {
        data.remove(0,1);
    }

    int i;
    for (i = 0; i < data.length(); i++)
    {
        if (data[i] == '\r')
        {
            break;
        }
    }
    data.remove(i,data.length()-i);

    double x = new_val.at(current_point).x();
    double new_y = data.toDouble();
    double old_y = new_val.at(current_point).y();

    new_val[current_point].setY(old_y+new_y);
    this->data[current_specter-1].append(new_y);

    QObject *object = engine->rootObjects().first();
    QMetaObject::invokeMethod(object,"set_specter_point",
                              Q_ARG(QVariant,current_point),
                              Q_ARG(QVariant,x),
                              Q_ARG(QVariant,old_y+new_y));
}

void Controller::saveBackup()
{
    QDir::setCurrent(QDir::homePath());
    saveXml("PES_BackupData.xml");
}

void Controller::loadBackup()
{
    QDir::setCurrent(QDir::homePath());
    QFile file("PES_BackupData.xml");

    if (!file.exists())
    {
        return;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        return;
    }

    QDomDocument document;

    if (!document.setContent(&file))
    {
        return;
    }

    QDomElement root = document.firstChildElement();

    operator_name = root.attribute("operator_name");
    specter_name = root.attribute("specter_name");
    cc_pressure = root.attribute("cc_pressure").toDouble();
    l_pressure = root.attribute("l_pressure").toDouble();
    he_current = root.attribute("he_current").toDouble();
    v_m_field = root.attribute("v_m_field").toDouble();
    h_m_field = root.attribute("h_m_field").toDouble();
    analyzer_pass_e = root.attribute("analyzer_pass_e").toDouble();
    channeltron_voltage = root.attribute("channeltron_voltage").toDouble();
    step_time = root.attribute("step_time").toUInt();
    e_max = root.attribute("e_max").toDouble();
    e_min = root.attribute("e_min").toDouble();
    e_ste = root.attribute("e_ste").toDouble();
    num_specters = root.attribute("num_specters").toUInt();

    QString asciipar4_alias = root.attribute("asciipar4_alias");
    QString counter_alias = root.attribute("counter_alias");

    asciipar4.setRsrcName(asciipar4_alias);
    counter.setRsrcName(counter_alias);

    data.clear();
    old_val.clear();
    new_val.clear();

    int n = round(float(e_max-e_min)/float(e_ste)) + 1;

    data.resize(root.childNodes().length());
    data.resize(num_specters);
    old_val.resize(n);
    new_val.resize(n);

    for (uint i = 0; i < num_specters; i++)
    {
        data[i].resize(n);
        QDomNode root_node_list = root.childNodes().at(i);
        QDomElement root_node_elem = root_node_list.toElement();
        QDomNodeList root_node_node_list = root_node_elem.childNodes();

        for (int j = 0; j < n; j++)
        {
            QDomNode point = root_node_node_list.at(j);
            QDomElement point_element = point.toElement();
            if (j > root_node_node_list.length())
            {
                data[i][j] = 0;
            }
            else
            {
                data[i][j] = point_element.attribute("y").toDouble();
            }
        }
    }

    QObject *object = engine->rootObjects().first();
    QMetaObject::invokeMethod(object,"set_specter_points",
                              Q_ARG(QVariant,n));
    QMetaObject::invokeMethod(object,"set_specter_axisX_max",
                              Q_ARG(QVariant,e_max));
    QMetaObject::invokeMethod(object,"set_specter_axisX_min",
                              Q_ARG(QVariant,e_min));

    for (int i = 0; i < n; i++)
    {
        double y = 0;
        double x = e_min + i*e_ste;

        for (uint j = 0; j < num_specters; j++)
        {
            y += data[j][i];
        }

        old_val[i].setX(x);
        old_val[i].setY(y);
        new_val[i] = old_val[i];

        QMetaObject::invokeMethod(object,"set_specter_point",
                                  Q_ARG(QVariant,i),
                                  Q_ARG(QVariant,old_val[i].x()),
                                  Q_ARG(QVariant,old_val[i].y()));
    }

    current_point = data.last().length();
    current_specter = data.length();

    setStartInfo();
}

void write_line(const QString &l_arg, QString &r_arg, QTextStream &stream)
{
    QString line;
    char aux_line[256] = "";

    sprintf(aux_line,"%-25s",l_arg.toStdString().data());
    line = aux_line;
    line += r_arg + "\n";
    stream << line;
}

void write_line(const QString &l_arg, double r_arg, QTextStream &stream)
{
    QString line;
    char aux_line[256] = "";

    sprintf(aux_line,"%-25s",l_arg.toStdString().data());
    line = aux_line;

    strcpy(aux_line,"");
    sprintf(aux_line,"%.4E",r_arg);
    line += aux_line;
    line += '\n';

    stream << line;
}

void Controller::saveTxt(const QString &file_name)
{
    QFile file(file_name);
    if (file.exists())
    {
        QFile::remove(file_name);
    }
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        return;
    }
    QTextStream stream(&file);

    QString line;
    QString aux;
    char aux_line[256];

    write_line("Operator name: ",operator_name,stream);
    write_line("Specter name: ",specter_name,stream);
    write_line("Col. Chamber pressure: ",cc_pressure,stream);
    write_line("Lamp pressure: ",l_pressure,stream);
    write_line("He current: ",he_current,stream);
    write_line("Vertical Mag. field: ",v_m_field,stream);
    write_line("Horizontal Mag. field: ",h_m_field,stream);
    write_line("Analizer Pass Energy: ",analyzer_pass_e,stream);
    write_line("Channeltron Voltage: ",channeltron_voltage,stream);
    write_line("Time per step: ",double(step_time),stream);
    stream << "\n";

    strcpy(aux_line,"");
    sprintf(aux_line,"%-30s","Energy");
    line = aux_line;

    for (int i = 0; i < data.length(); i++)
    {
        strcpy(aux_line,"");
        aux = QString("Counts_");
        aux += QString::number(i);
        sprintf(aux_line,"%-30s",aux.toStdString().data());

        line += QString(aux_line);
    }
    line += '\n';
    stream << line;

    int n = round(float(e_max-e_min)/float(e_ste)) + 1;

    for (int i = 0; i < n; i++)
    {
        line.clear();
        strcpy(aux_line,"");

        double x = e_min + i*e_ste;
        sprintf(aux_line,"%-30.4E",x);
        line += aux_line;

        for (int j = 0; j < data.length(); j++)
        {
            double y = 0;
            if (i < data[j].length())
            {
                y = data.at(j).at(i);
            }

            strcpy(aux_line,"");
            sprintf(aux_line,"%-30.4E",y);
            line += aux_line;
        }

        line += '\n';
        stream << line;
    }

    file.close();
}

void Controller::saveXml(const QString &file_name)
{
    QDomDocument document;
    QDomElement root = document.createElement("PES-Specter");
    document.appendChild(root);

    root.setAttribute("operator_name",operator_name);
    root.setAttribute("specter_name",specter_name);
    root.setAttribute("cc_pressure",cc_pressure);
    root.setAttribute("l_pressure",l_pressure);
    root.setAttribute("he_current",he_current);
    root.setAttribute("v_m_field",v_m_field);
    root.setAttribute("h_m_field",h_m_field);
    root.setAttribute("analyzer_pass_e",analyzer_pass_e);
    root.setAttribute("channeltron_voltage",channeltron_voltage);
    root.setAttribute("step_time",step_time);
    root.setAttribute("e_max",e_max);
    root.setAttribute("e_min",e_min);
    root.setAttribute("e_ste",e_ste);
    root.setAttribute("num_specters",num_specters);
    root.setAttribute("asciipar4_alias",asciipar4.resourceName());
    root.setAttribute("counter_alias",counter.resourceName());

    int n = round(float(e_max-e_min)/float(e_ste)) + 1;
    for (int i = 0; i < data.length(); i++)
    {
        QDomElement spec = document.createElement("specter");
        for (int j = 0; j < n; j++)
        {
            QDomElement spec_point = document.createElement("point");
            double x = e_min + e_ste*j;
            double y;

            if (j < data.at(i).length())
            {
                y = data.at(i).at(j);
            }
            else
            {
                 y = 0;
            }

            spec_point.setAttribute("y",y);
            spec_point.setAttribute("x",x);
            spec.appendChild(spec_point);
        }
        root.appendChild(spec);
    }

    QFile file(file_name);
    if (file.exists())
    {
        QFile::remove(file_name);
    }
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream stream(&file);
    stream << document.toString();
    file.close();
}
