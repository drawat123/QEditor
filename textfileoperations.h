#ifndef TEXTFILEOPERATIONS_H
#define TEXTFILEOPERATIONS_H

#include <QFile>
#include <QObject>
#include <QString>
#include <QTextStream>
#include <QUrl>

#include <QFontMetrics>
#include <QRect>
#include <QtMath>

class TextFileOperations : public QObject
{
    Q_OBJECT
public:
    explicit TextFileOperations(QObject *parent = nullptr);

signals:

public slots:
    QString readFile(const QUrl &filePath);
    void saveFile(const QUrl &filePath, QString editorText);
    QString spacesBetweenTexts(QString firstText, QString secondText, QFont font, int rectWidth);
};

#endif // TEXTFILEOPERATIONS_H
