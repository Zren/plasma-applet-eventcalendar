#include "volumepeaks.h"

VolumePeaks::VolumePeaks(QObject *parent) : QObject(parent),
m_process(0),
m_peaking(false),
m_defaultSinkPeak(0),
m_peakCommand("")
{

}

VolumePeaks::~VolumePeaks() {
    stop();
}

bool VolumePeaks::peaking() const {
    return m_peaking;
}
void VolumePeaks::setPeaking(bool b) {
    if (b != m_peaking) {
        m_peaking = b;
        emit peakingChanged();
        if (m_peaking) {
            run();
        } else {
            stop();
        }
        
    }
}

int VolumePeaks::defaultSinkPeak() const {
    return m_defaultSinkPeak;
}
void VolumePeaks::setDefaultSinkPeak(int peak) {
    if (peak != m_defaultSinkPeak) {
        m_defaultSinkPeak = peak;
        emit defaultSinkPeakChanged();
    }
}

QString VolumePeaks::peakCommand() const {
    return m_peakCommand;
}
void VolumePeaks::setPeakCommand(const QString &command) {
    if (command != m_peakCommand) {
        m_peakCommand = command;
        emit peakCommandChanged();
        restart();
    }
}

void VolumePeaks::readyReadStandardOutput() {
    QByteArray data = m_process->readAllStandardOutput();
    QList<QByteArray> tokens = data.split('\n');

    // TODO: Maybe just asign the last token?
    // If it's running behind, we shouldn't cause excess UI updates.
    for (int i = 0; i < tokens.size(); ++i) {
        QByteArray token = tokens.at(i);
        if (!token.isEmpty()) {
            bool ok;
            int peak = token.toInt(&ok);
            if (ok) {
                setDefaultSinkPeak(peak);
            }
        }
    }
}

void VolumePeaks::run() {
    if (m_peakCommand.isEmpty())
        return;

    m_process = new QProcess(this);
    connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(readyReadStandardOutput()));
    m_process->start(m_peakCommand);
}


void VolumePeaks::stop() {
    if (m_process) {
        m_process->close();
        disconnect(m_process, 0, this, 0);
        delete m_process;
    }
}

void VolumePeaks::restart() {
    stop();
    run();
}
