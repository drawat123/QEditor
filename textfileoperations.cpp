#include "textfileoperations.h"
#include <QDebug>

TextFileOperations::TextFileOperations(QObject *parent)
    : QObject{parent}
{}

QString TextFileOperations::readFile(const QUrl &filePath)
{
    QFile file(filePath.toLocalFile());

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open the file.";
        return "";
    }

    QTextStream in(&file);
    QString fileContents = in.readAll();

    file.close();

    return fileContents;
}

void TextFileOperations::saveFile(const QUrl &filePath, QString editorText)
{
    QFile file(filePath.toLocalFile());

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Failed to open the file.";
        return;
    }

    QTextStream out(&file);
    out << editorText;

    file.close();
}

QString TextFileOperations::spacesBetweenTexts(QString firstText,
                                               QString secondText,
                                               QFont font,
                                               int rectWidth)
{
    QFontMetrics fontMetrics(font);
    int firstTextWidth = fontMetrics.width(firstText);
    int secondTextWidth = fontMetrics.width(secondText);

    int spacesCount = qFloor((rectWidth - firstTextWidth - secondTextWidth)
                             / fontMetrics.width(' '));

    QString str = "";
    for (int i = 0; i < spacesCount - 7; i++)
        str += ' ';

    return str;
}
